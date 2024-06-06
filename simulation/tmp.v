module pixel_generator(
    input           out_stream_aclk,
    input           s_axi_lite_aclk,
    input           axi_resetn,
    input           periph_resetn,

    // Stream output
    output  [31:0]   out_stream_tdata,
    output [3:0]     out_stream_tkeep,
    output           out_stream_tlast,
    input            out_stream_tready,
    output           out_stream_tvalid,
    output  [0:0]    out_stream_tuser, 

    // AXI-Lite S
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


// Write to the register file, use a state machine to track address write, data write, and response read events
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
                writeAddr <= s_axi_lite_awaddr[7:2];
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


localparam max_iteration = 100;

// parameter REAL_OFFSET = -2.0;  // Corresponding to -2.0 in floating point
// parameter REAL_RANGE = 3.0;    // Width of 3 in the real axis
// parameter IMAG_OFFSET = -1.5;  // Corresponding to -1.5 in floating point
// parameter IMAG_RANGE = 3.0;    // Height of 3 in the imaginary axis

localparam REAL_OFFSET = 32'hC0000000; // Corresponding to -2.0 in floating point
localparam REAL_RANGE = 32'h40400000;  // Corresponding to 3.0 in floating point
localparam IMAG_OFFSET = 32'hBF800000; // Corresponding to -1.5 in floating point
localparam IMAG_RANGE = 32'h40400000;  // Corresponding to 3.0 in floating point

localparam [1:0]
    START = 2'b01,
    ITERATE = 2'b10,
    OUTPUT = 2'b11;
reg [1:0]            state = START;

// Floating-point wires and registers
reg [31:0] zr, zi, c_re, c_im;
wire [31:0] zr_squared, zi_squared, two_zr_zi, zr_new, zi_new;
wire [31:0] zr_temp, zi_temp;


// Instantiate floating-point operations
fp_mult mult_zr_square (.clk(out_stream_aclk), .a(zr), .b(zr), .result(zr_squared));
fp_mult mult_zi_square (.clk(out_stream_aclk), .a(zi), .b(zi), .result(zi_squared));
fp_mult mult_two_zr_zi (.clk(out_stream_aclk), .a(zr), .b(zi), .result(two_zr_zi));
fp_add sub_zr_zi_squared (.clk(out_stream_aclk), .a(zr_squared), .b(~zi_squared + 1), .result(zr_temp)); // zr_squared - zi_squared
fp_add add_zr_temp_c_re (.clk(out_stream_aclk), .a(zr_temp), .b(c_re), .result(zr_new)); // zr_temp + c_re
fp_add add_two_zr_zi_c_im (.clk(out_stream_aclk), .a(two_zr_zi), .b(c_im), .result(zi_new)); // 2*zr*zi + c_im

reg [9:0] x; 
reg [8:0] y;
reg [7:0] iter_count;
wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);
wire [23:0] color;

always @(posedge out_stream_aclk) begin
        case(state)
            START: begin
            if (periph_resetn) begin
                iter_count <= 0;
                c_re <= REAL_OFFSET + (REAL_RANGE * x / X_SIZE); 
                c_im <= IMAG_OFFSET + (IMAG_RANGE * y / Y_SIZE);
                zr <= 0;  
                zi <= 0;  
                state <= ITERATE;
            end
            else begin
                x <= 0;
                y <= 0;
                state <= START;
            end
            end

            ITERATE: begin
            if (periph_resetn) begin
                // temp_zr = zr_squared - zi_squared + c_re;
                // temp_zi = two_zr_zi + c_im;
                if ((zr_squared + zi_squared > 32'h40800000) || iter_count == max_iteration-1) begin
                    iter_count <= iter_count+1;
                    state <= OUTPUT;
                end else begin
                    zr <= zr_new; // Changed temp_zr to zr_new
                    zi <= zi_new; // Changed temp_zi to zi_new

                    iter_count <= iter_count + 1;
                    state <= ITERATE;
                end
            end
            else begin
                x <= 0;
                y <= 0;
                state <= START;
            end
            end

            OUTPUT: begin
            if (periph_resetn) begin 
                iter_count <= 0;
                zr <= 0;
                zi <= 0;
                if (lastx) begin
                    x <= 9'd0;
                    if (lasty) begin
                        y <= 8'd0;
                    end
                    else begin
                        y <= y + 8'd1;
                    end
                end
                else x <= x + 9'd1;
                if(out_stream_tready)begin
                    state <= START; // Move to start to process the next pixel if 
                end
            end
            else begin
                x <= 0;
                y <= 0;
                state <= START;
            end
            end

            default: begin
                state <= START;
            end
        endcase
end

wire valid;
assign valid = (state == OUTPUT);

reg [23:0] data; 

always @(*) begin
    if ((iter_count == max_iteration))begin
        data = 24'h000000; 
    end
    else begin
        data[23:16] = (iter_count*3 ) % 256;  // Red component based on iteration count
        data[15:8] = (iter_count*2) % 256;  // Green component
        data[7:0] = (iter_count*1) % 256;  // Blue component
    end
end

wire [7:0] r, g, b;
assign r = data[23:16];
assign g = data[15:8];
assign b = data[7:0];


    simulator pixel_simulator(
    .aclk(aclk),
    .aresetn(aresetn),
    .r(r),
    .g(g),
    .b(b),
    .simu_stream_tdata(color), 
    .valid(valid)
    );

    // packer pixel_packer(    .aclk(out_stream_aclk),
    //                     .aresetn(periph_resetn),
    //                     .r(r), .g(g), .b(b),
    //                     .eol(lastx), .in_stream_ready(ready), .valid(valid), .sof(first),
    //                     .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
    //                     .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
    //                     .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

                       
endmodule

