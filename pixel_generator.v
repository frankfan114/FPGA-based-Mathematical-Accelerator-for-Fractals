module pixel_generator(
input           out_stream_aclk,
input           s_axi_lite_aclk,
input           axi_resetn,
input           periph_resetn,

//Stream output
output [31:0]   out_stream_tdata,
output [3:0]    out_stream_tkeep,
output          out_stream_tlast,
input           out_stream_tready,
output          out_stream_tvalid,
output [0:0]    out_stream_tuser, 

//AXI-Lite S
input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_araddr,
output          s_axi_lite_arready,
input           s_axi_lite_arvalid,

input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_awaddr,
output          s_axi_lite_awready,
input           s_axi_lite_awvalid,

input           s_axi_lite_bready,
output [1:0]    s_axi_lite_bresp,
output          s_axi_lite_bvalid,

output [31:0]   s_axi_lite_rdata,
input           s_axi_lite_rready,
output [1:0]    s_axi_lite_rresp,
output          s_axi_lite_rvalid,

input  [31:0]   s_axi_lite_wdata,
output          s_axi_lite_wready,
input           s_axi_lite_wvalid

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
    
    readData <= regfile[readAddr];

    if (!axi_resetn) begin
    readState <= AWAIT_RADD;
    end

    else case (readState)

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

assign s_axi_lite_arready = (readState == AWAIT_RADD);
assign s_axi_lite_rresp = (readAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;
assign s_axi_lite_rvalid = (readState == AWAIT_READ);
assign s_axi_lite_rdata = readData;

//Write to the register file, use a state machine to track address write, data write and response read events
always @(posedge s_axi_lite_aclk) begin

    if (!axi_resetn) begin
        writeState <= AWAIT_WADD_AND_DATA;
    end

    else case (writeState)

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

assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;



// Mandelbrot parameters
localparam integer max_iteration = 255;


localparam real SCALE_REAL = 4.0 / X_SIZE;
localparam real SCALE_IMAG = 3.0 / Y_SIZE;
localparam real OFFSET_REAL = -3.0; // Real offset to map [-3, 1] in complex plane
localparam real OFFSET_IMAG = -1.5; // Imaginary offset to map [-1.5, 1.5] in complex plane

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire [7:0] red, green, blue;

always @(posedge out_stream_aclk) begin // iterate one pixel per cycle
    if (periph_resetn) begin
        if (out_stream_tready & out_stream_tvalid) begin
            if (lastx) begin
                x <= 9'd0;
                if (lasty) begin
                    y <= 9'd0;
                end
                else begin
                    y <= y + 9'd1;
                end
            end
            else begin
                x <= x + 9'd1;
            end
        end
        out_stream_tvalid <= 1'b1;
        {red, green, blue} <= compute_mandelbrot(x, y);
    end
    else begin
        x <= 0;
        y <= 0;
        out_stream_tvalid <= 1'b0;
    end
end



function [23:0] compute_mandelbrot;
    input [9:0] px;
    input [8:0] py;
    real cr, ci, zr, zi, zr2, zi2;
    integer i;
    reg [15:0] density;
    reg escape; // Flag to control when to stop iterating
    begin
        cr = OFFSET_REAL + px * SCALE_REAL;
        ci = OFFSET_IMAG + py * SCALE_IMAG;
        zr = 0;
        zi = 0;
        density = 0;
        escape = 0; // Initialize the escape flag to false
        for (i = 0; i < max_iteration && !escape; i = i + 1) begin
            zr2 = zr * zr;
            zi2 = zi * zi;
            if (zr2 + zi2 > 4.0) begin
                escape = 1; // Set the escape flag to true to stop iterating
            end else begin
                zi = 2 * zr * zi + ci;
                zr = zr2 - zi2 + cr;
                density = density + 1; // Increment density for paths
            end
        end
        // Simple non-linear color mapping based on density
        compute_mandelbrot[23:16] = (density * density) % 256;  // Red component
        compute_mandelbrot[15:8]  = (density * density * density) % 256; // Green component
        compute_mandelbrot[7:0]   = (density) % 256;  // Blue component
    end
endfunction


// Function to generate color based on iteration count
function [23:0] palette;
    input [7:0] iter;
    reg [7:0] r, g, b;
    begin
        // Example color palette
        r = iter * 1; // Red component
        g = iter * 2; // Green component
        b = iter * 3; // Blue component
        palette = {r, g, b};
    end
endfunction

always @(*) begin
    {out_stream_tdata[31:24], out_stream_tdata[23:16], out_stream_tdata[15:8]} = compute_mandelbrot(x, y);
    out_stream_tdata[7:0] = 8'd0; // Padding the LSB of data with zero
    out_stream_tkeep = 4'b1111;   // Assuming all bytes are valid
    out_stream_tlast = lastx & lasty; // End of frame
    out_stream_tuser = first;     // Indicate the first pixel
end

// combine 8-bit R, G, B values into 24-bit color
simulator pixel_simulator(
    .aclk(out_stream_aclk),
    .aresetn(periph_resetn),
    .r(out_stream_tdata[31:24]), 
    .g(out_stream_tdata[23:16]), 
    .b(out_stream_tdata[15:8])
);
// wire valid_int = 1'b1;

// packer pixel_packer(    .aclk(out_stream_aclk),
//                         .aresetn(periph_resetn),
//                         .r(r), .g(g), .b(b),
//                         .eol(lastx), .in_stream_ready(ready), .valid(valid_int), .sof(first),
//                         .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
//                         .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
//                         .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

 
endmodule
