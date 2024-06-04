module pixel_generator(
    input           out_stream_aclk,
    input           s_axi_lite_aclk,
    input           axi_resetn,
    input           periph_resetn,

    // Stream output
    output [31:0]   out_stream_tdata,
    output [3:0]    out_stream_tkeep,
    output          out_stream_tlast,
    input           out_stream_tready,
    output          out_stream_tvalid,
    output [0:0]    out_stream_tuser, 

    // AXI-Lite S
    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr,
    output          s_axi_lite_arready,
    input           s_axi_lite_arvalid,

    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr,
    output          s_axi_lite_awready,
    input           s_axi_lite_awvalid,

    input           s_axi_lite_bready,
    output [1:0]    s_axi_lite_bresp,
    output          s_axi_lite_bvalid,

    output [31:0]   s_axi_lite_rdata,
    input           s_axi_lite_rready,
    output [1:0]    s_axi_lite_rresp,
    output          s_axi_lite_rvalid,

    input [31:0]    s_axi_lite_wdata,
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

reg [31:0] regfile [REG_FILE_SIZE-1:0];
reg [AXI_LITE_ADDR_WIDTH-3:0] writeAddr, readAddr;
reg [31:0] readData, writeData;
reg [1:0] readState = AWAIT_RADD;
reg [2:0] writeState = AWAIT_WADD_AND_DATA;


// Read from the register file
always @(posedge s_axi_lite_aclk) begin
    readData <= regfile[readAddr];

    if (!axi_resetn) begin
        readState <= AWAIT_RADD;
    end else case (readState)
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

// Write to the register file, use a state machine to track address write, data write and response read events
always @(posedge s_axi_lite_aclk) begin
    if (!axi_resetn) begin
        writeState <= AWAIT_WADD_AND_DATA;
    end else case (writeState)
        AWAIT_WADD_AND_DATA: begin
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

        AWAIT_WDATA: begin
            if (s_axi_lite_wvalid) begin
                writeData <= s_axi_lite_wdata;
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WADD: begin
            if (s_axi_lite_awvalid) begin
                writeAddr <= s_axi_lite_awaddr[7:2];
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WRITE: begin
            regfile[writeAddr] <= writeData;
            writeState <= AWAIT_RESP;
        end

        AWAIT_RESP: begin
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



// Design
// start-> iterate -> done

localparam SCALE_FACTOR = 64; // 2^10 for fixed-point precision

// Redefine real constants using fixed-point
localparam integer OFFSET_REAL = -3.0 *SCALE_FACTOR; // -3.0 * 1024
localparam integer OFFSET_IMAG = -1.5*SCALE_FACTOR; // -1.5 * 1024
localparam integer SCALE_REAL = ( 4.0 )*SCALE_FACTOR / X_SIZE; // (1.0 - (-3.0)) * 1024 / 640
localparam integer SCALE_IMAG = (3.0)*SCALE_FACTOR / Y_SIZE; // (1.5 - (-1.5)) * 1024 / 480

localparam integer max_iteration = 15;


reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

always @(posedge out_stream_aclk) begin
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
    end
    else begin
        x <= 0;
        y <= 0;
    end
end

always @(posedge out_stream_aclk) begin
    
    if (periph_resetn) begin
        computeState <= AWAIT_DATA;
    end 
    
    else case (computeState)
        AWAIT_DATA: begin
            case ({s_axi_lite_awvalid, s_axi_lite_wvalid})
                2'b10: begin
                    writeAddr <= s_axi_lite_awaddr[7:2];
                    computeState <= AWAIT_WDATA;
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

            computeState<= Iterate;
        end

        Iterate: begin
            case ({complete, max})
                2'b11: begin
                    
                    compute_mandelbrot[23:16] <= (density * density) % 256;  // Red component
                    compute_mandelbrot[15:8]  <= (density * density * density) % 256; // Green component
                    compute_mandelbrot[7:0]   <= (density) % 256; 
                
                    computeState<= Done;
                end
                2'b10: begin
                    
                end
                2'b01: begin
                    
                end
                2'b00: begin
                    
                end

                
            endcase

            else if (condition) begin
                
            end begin
               i<= i+1;

               computeState <= Iterate; 
            end
        end
        // valid and ready 
        Done: begin
            if (s_axi_lite_awvalid) begin
                writeAddr <= s_axi_lite_awaddr[7:2];
                writeState <= AWAIT_WRITE;
            end
        end

        default: begin
            computeState <= AWAIT_DATA;
        end
    endcase
end

// Compute Mandelbrot set pixel, using fixed-point arithmetic
function [23:0] compute_mandelbrot;
    input [9:0] px;
    input [8:0] py;
    integer cr, ci, zr, zi;
    integer i;
    reg [15:0] density;
    reg escape; // Flag to control when to stop iterating
    begin
        cr = OFFSET_REAL + px * SCALE_REAL;
        ci = OFFSET_IMAG + py * SCALE_IMAG;
        zr = 0;
        zi = 0;
        density = 0;
        escape = 0;
        for (i = 0; i < max_iteration && !escape; i = i + 1) begin
            if (zr * zr + zi * zi > 4 * SCALE_FACTOR * SCALE_FACTOR) begin
                escape = 1; // Set the escape flag to true to stop iterating
            end else begin
                zi = 2 * zr * zi + ci;
                zr = zr * zr - zi * zi+ cr;
                density = density + 1; // Increment density for paths
            end
        end
        compute_mandelbrot[23:16] = (density * density) % 256;  // Red component
        compute_mandelbrot[15:8]  = (density * density * density) % 256; // Green component
        compute_mandelbrot[7:0]   = (density) % 256;  // Blue component
    end
endfunction



wire valid_int = 1'b1;
wire [23:0] rgb;
assign rgb = compute_mandelbrot(x, y);

packer pixel_packer(
    .aclk(out_stream_aclk),
    .aresetn(periph_resetn),
    .r(rgb[23:16]),
    .g(rgb[15:8]),
    .b(rgb[7:0]),
    .eol(lastx),
    .in_stream_ready(out_stream_tready & out_stream_tvalid),
    .valid(valid_int),
    .sof(first),
    .out_stream_tdata(out_stream_tdata),
    .out_stream_tkeep(out_stream_tkeep),
    .out_stream_tlast(out_stream_tlast),
    .out_stream_tready(out_stream_tready),
    .out_stream_tvalid(out_stream_tvalid),
    .out_stream_tuser(out_stream_tuser)
);
endmodule
