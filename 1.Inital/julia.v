module pixel_generator(
    input           out_stream_aclk,
    input           s_axi_lite_aclk,
    input           axi_resetn,
    input           periph_resetn,

    //Stream output
    output reg [31:0]   out_stream_tdata,
    output [3:0]    out_stream_tkeep,
    output          out_stream_tlast,
    input           out_stream_tready,
    output reg        out_stream_tvalid,
    output reg [0:0]    out_stream_tuser, 

    //AXI-Lite S
    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr,
    output                          s_axi_lite_arready,
    input                           s_axi_lite_arvalid,

    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr,
    output                          s_axi_lite_awready,
    input                           s_axi_lite_awvalid,

    input                           s_axi_lite_bready,
    output [1:0]                    s_axi_lite_bresp,
    output                          s_axi_lite_bvalid,

    output [31:0]                   s_axi_lite_rdata,
    input                           s_axi_lite_rready,
    output [1:0]                    s_axi_lite_rresp,
    output                          s_axi_lite_rvalid,

    input [31:0]                    s_axi_lite_wdata,
    output                          s_axi_lite_wready,
    input                           s_axi_lite_wvalid
);

localparam X_SIZE = 640;
localparam Y_SIZE = 480;
localparam REG_FILE_SIZE = 8;
parameter AXI_LITE_ADDR_WIDTH = 8;

localparam AWAIT_WADD_AND_DATA = 3'b000;
localparam AWAIT_WDATA = 3'b001;
localparam AWAIT_WADD = 3'b010;
localparam AWAIT_WRITE = 3'b100;
localparam AWAIT_RESP = 3'b101;

localparam AWAIT_RADD = 2'b00;
localparam AWAIT_FETCH = 2'b01;
localparam AWAIT_READ = 2'b10;

localparam AXI_OK = 2'b00;
localparam AXI_ERR = 2'b10;

reg [31:0]                          regfile [REG_FILE_SIZE-1:0];
reg [AXI_LITE_ADDR_WIDTH-3:0]       writeAddr, readAddr;
reg [31:0]                          readData, writeData;
reg [1:0]                           readState = AWAIT_RADD;
reg [2:0]                           writeState = AWAIT_WADD_AND_DATA;

//Read from the register file
always @(posedge s_axi_lite_aclk) begin
    if (!axi_resetn) begin
        readState <= AWAIT_RADD;
    end else begin
        case (readState)
            AWAIT_RADD: begin
                if (s_axi_lite_arvalid) begin
                    readAddr <= s_axi_lite_araddr[7:2];
                    readState <= AWAIT_FETCH;
                end
            end
            AWAIT_FETCH: begin
                readState <= AWAIT_READ;
            end
            AWAIT_READ: begin
                if (s_axi_lite_rready) begin
                    readState <= AWAIT_RADD;
                end
            end
            default: begin
                readState <= AWAIT_RADD;
            end
        endcase
    end
end

assign s_axi_lite_arready = (readState == AWAIT_RADD);
assign s_axi_lite_rresp = (readAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;
assign s_axi_lite_rvalid = (readState == AWAIT_READ);
assign s_axi_lite_rdata = regfile[readAddr];

//Write to the register file, use a state machine to track address write, data write and response read events
always @(posedge s_axi_lite_aclk) begin
    if (!axi_resetn) begin
        writeState <= AWAIT_WADD_AND_DATA;
    end else begin
        case (writeState)
            AWAIT_WADD_AND_DATA: begin  //Idle, awaiting a write address or data
                case ({s_axi_lite_awvalid, s_axi_lite_wvalid})
                    2'b10: begin
                        writeAddr <= s_axi_lite_awaddr[7:2];
                        writeState <= AWAIT_WDATA;
                    end
                    2'b01: begin
                        writeData <= s_axi_lite_wdata;
                        writeState <= AWAIT_WADD;
                    end
                    2'b11: begin
                        writeData <= s_axi_lite_wdata;
                        writeAddr <= s_axi_lite_awaddr[7:2];
                        writeState <= AWAIT_WRITE;
                    end
                    default: begin
                        writeState <= AWAIT_WADD_AND_DATA;
                    end
                endcase        
            end
            AWAIT_WDATA: begin //Received address, waiting for data
                if (s_axi_lite_wvalid) begin
                    writeData <= s_axi_lite_wdata;
                    writeState <= AWAIT_WRITE;
                end
            end
            AWAIT_WADD: begin //Received data, waiting for address
                if (s_axi_lite_awvalid) begin
                    writeData <= s_axi_lite_wdata;
                    writeState <= AWAIT_WRITE;
                end
            end
            AWAIT_WRITE: begin //Perform the write
                regfile[writeAddr] <= writeData;
                writeState <= AWAIT_RESP;
            end
            AWAIT_RESP: begin //Wait to send response
                if (s_axi_lite_bready) begin
                    writeState <= AWAIT_WADD_AND_DATA;
                end
            end
            default: begin
                writeState <= AWAIT_WADD_AND_DATA;
            end
        endcase
    end
end

assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;

localparam integer max_iteration = 255;
localparam real re_max = 1.5;
localparam real re_min = -1.5;
localparam real im_max = 1.2;
localparam real im_min = -1.2;
localparam real SCALE_REAL = (re_max - re_min) / X_SIZE;
localparam real SCALE_IMAG = (im_max - im_min) / Y_SIZE;
localparam real OFFSET_REAL = re_min;
localparam real OFFSET_IMAG = im_min;

// Fixed complex constant C for Julia set
localparam real c_re = -0.835;
localparam real c_im = -0.2321;

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

always @(posedge out_stream_aclk or negedge periph_resetn) begin
    if (!periph_resetn) begin
        x <= 0;
        y <= 0;
        out_stream_tvalid <= 1'b0;
    end else begin
        if (out_stream_tready & out_stream_tvalid) begin
            if (lastx) begin
                x <= 0;
                if (lasty) y <= 0;
                else y <= y + 1;
            end else x <= x + 1;
        end
        out_stream_tvalid <= 1'b1;
    end
end

function [23:0] compute_julia;
    input [9:0] px;
    input [8:0] py;
    real zr, zi, zr2, zi2;
    integer i;
    reg [15:0] density;
    reg escape; // Flag to control when to stop iterating
    reg [7:0] red, green, blue;
    begin
        zr = OFFSET_REAL + px * SCALE_REAL;
        zi = OFFSET_IMAG + py * SCALE_IMAG;
        density = 0;
        escape = 0; // Initialize the escape flag to false
        for (i = 0; i < max_iteration && !escape; i = i + 1) begin
            zr2 = zr * zr;
            zi2 = zi * zi;
            if (zr2 + zi2 > 4.0) begin
                escape = 1; // Set the escape flag to true to stop iterating
            end else begin
                zi = 2 * zr * zi + c_im;
                zr = zr2 - zi2 + c_re;
                density = density + 1; // Increment density for paths
            end
        end

        // Simple non-linear color mapping based on density
        if (density == max_iteration) begin
            red = 0;
            green = 0;
            blue = 0;
        end else begin
            red = (density * density) % 256; // Red component
            green = (density * density * density) % 256; // Green component
            blue = (density) % 256; // Blue component
        end

        compute_julia = {red, green, blue};
    end
endfunction

always @(*) begin
    {out_stream_tdata[31:24], out_stream_tdata[23:16], out_stream_tdata[15:8]} = compute_julia(x, y);
    out_stream_tdata[7:0] = 8'd0; // Padding the LSB of data with zero

end

// Instantiating the simulator module
simulator pixel_simulator(
    .aclk(out_stream_aclk),
    .aresetn(periph_resetn),
    .r(out_stream_tdata[31:24]),
    .g(out_stream_tdata[23:16]),
    .b(out_stream_tdata[15:8])
);

endmodule