module pixel_generator(
    input           out_stream_aclk,
    input           s_axi_lite_aclk,
    input           axi_resetn,
    input           periph_resetn,

    // Stream output
    output reg [31:0]   out_stream_tdata,
    output reg [3:0]    out_stream_tkeep,
    output reg          out_stream_tlast,
    input               out_stream_tready,
    output reg          out_stream_tvalid,
    output reg [0:0]    out_stream_tuser, 

    // AXI-Lite S
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


// Read from the register file
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

// Write to the register file, use a state machine to track address write, data write and response read events
always @(posedge s_axi_lite_aclk) begin
    if (!axi_resetn) begin
        writeState <= AWAIT_WADD_AND_DATA;

    end else case (writeState)
        AWAIT_WADD_AND_DATA: begin  // Idle, awaiting a write address or data
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

        AWAIT_WDATA: begin // Received address, waiting for data
            if (s_axi_lite_wvalid) begin
                writeData <= s_axi_lite_wdata;
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WADD: begin // Received data, waiting for address
            if (s_axi_lite_awvalid) begin
                writeAddr <= s_axi_lite_awaddr[7:2];
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WRITE: begin // Perform the write
            regfile[writeAddr] <= writeData;
            writeState <= AWAIT_RESP;
        end

        AWAIT_RESP: begin // Wait to send response
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

localparam integer max_iteration = 100;

parameter integer SCALE_FACTOR = 64; // 2^16 for fixed-point precision

localparam real re_max=1.0 ;
localparam real re_min=-3.0; 
localparam real im_max=1.5; 
localparam real im_min=-1.5;

// Convert real constants to fixed-point
localparam SCALE_REAL = (re_max - re_min) * SCALE_FACTOR / X_SIZE;
localparam SCALE_IMAG = (im_max - im_min) * SCALE_FACTOR / Y_SIZE;
localparam OFFSET_REAL = re_min * SCALE_FACTOR; // Real offset
localparam OFFSET_IMAG = im_min * SCALE_FACTOR; // Imaginary offset

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

reg [1:0] state;
localparam STATE_IDLE = 2'b00,
           STATE_OUTPUT = 2'b10,
           STATE_ITERATE = 2'b11;

reg [23:0] mandelbrot_rgb;
reg [15:0] density;
reg escape;

real cr, ci, zr, zi, zr2, zi2;
integer i;

// Compute the initial values for the Mandelbrot calculation
task initialize_mandelbrot;
    input [9:0] px;
    input [8:0] py;
    begin
        cr = OFFSET_REAL + px * SCALE_REAL;
        ci = OFFSET_IMAG + py * SCALE_IMAG;
        zr = 0;
        zi = 0;
        density = 0;
        escape = 0;
        i = 0;
    end
endtask

// Perform one iteration of the Mandelbrot calculation
task iterate_mandelbrot;
    begin
        zr2 = zr * zr;
        zi2 = zi * zi;
        if (zr2 + zi2 > 4.0) begin
            escape = 1;
        end else begin
            zi = 2 * zr * zi + ci;
            zr = zr2 - zi2 + cr;
            density = density + 1;
        end
        i = i + 1;
    end
endtask

// Finalize the Mandelbrot calculation and set the RGB value
task finalize_mandelbrot;
    begin
        mandelbrot_rgb[23:16] = (density * density) % 256;  // Red component
        mandelbrot_rgb[15:8]  = (density * density * density) % 256; // Green component
        mandelbrot_rgb[7:0]   = (density) % 256;  // Blue component
    end
endtask


//
reg valid_int;

always @(posedge out_stream_aclk) begin
    if (periph_resetn) begin
        x <= 0;
        y <= 0;
        out_stream_tvalid <= 1'b0;
        state <= STATE_IDLE;

    end else begin
        case (state)
            STATE_IDLE: begin
                if (out_stream_tready) begin
                    initialize_mandelbrot(x, y);
                    state <= STATE_ITERATE;
                    valid_int <= 1'b0;
                end
            end

            STATE_ITERATE: begin
                if (i < max_iteration && !escape) begin
                    iterate_mandelbrot;
                    
                end else begin
                    finalize_mandelbrot;
                    state <= STATE_OUTPUT;
                end
            end

            STATE_OUTPUT: begin
                if (out_stream_tready) begin
                    out_stream_tdata <= {mandelbrot_rgb, 8'd0}; // Padding the LSB of data with zero
                    // out_stream_tkeep <= 4'b1111;   // Assuming all bytes are valid
                    // out_stream_tlast <= lastx & lasty; // End of frame
                    // out_stream_tuser <= first;     // Indicate the first pixel
                    valid_int <= 1'b1;

                    if (lastx) begin
                        x <= 9'd0;
                        if (lasty) begin
                            y <= 9'd0;
                        end else begin
                            y <= y + 9'd1;
                        end
                    end else begin
                        x <= x + 9'd1;
                    end

                    state <= STATE_IDLE;
                end
            end

            default: state <= STATE_IDLE;
        endcase
    end
end

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