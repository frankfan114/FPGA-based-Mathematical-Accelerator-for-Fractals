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


//


initial begin
   regfile[0] = 32'hD5003B;
//    regfile[1] = 32'h10150;
   regfile[1] = 32'h10164;
   regfile[2] = 32'h1800133;
end

wire [7:0] max_iteration = regfile[1][7:0];
wire [15:0] SCALE_REAL = 2*regfile[2][31:16];
wire [15:0] SCALE_IMAG = 2*regfile[2][15:0];
wire [31:0] OFFSET_REAL = regfile[2][31:16];
wire [31:0] OFFSET_IMAG = regfile[2][15:0];

localparam SCALE_FACTOR = 256;
localparam X_SIZE = 640;
localparam Y_SIZE = 480;

localparam [2:0]
    MSTART = 3'b000,
    MITERATE = 3'b001,
    MCHECK = 3'b010,
    OUTPUT = 3'b011,
    JSTART = 3'b100,
    JITERATE = 3'b101,
    JCHECK = 3'b110;

reg [2:0]  state = MSTART; 
reg [2:0]  state1 = MSTART; 

//pass state machine
localparam [1:0]
    GEN = 2'b00,
    PASS = 2'b01;
reg [1:0]            pixel_pass = GEN;

wire switch = (max_iteration == 8'd80);

reg [9:0] x,x1; 
reg [8:0] y,y1;

reg [7:0] iter_count,iter_count1;
reg [7:0] iter_final,iter_final1;

reg signed [13:0] zr, zi, c_im, c_re; // min14bit
reg signed [13:0] zr1, zi1, c_im1, c_re1; // min14bit

reg signed [18:0] zr2, zi2; //min19bit
reg signed [18:0] zr21, zi21; //min19bit

localparam limit= 4*SCALE_FACTOR*SCALE_FACTOR;


wire first = (x == 0) & (y == 0);

wire lastx = (x == X_SIZE - 2);
wire lasty = (y == Y_SIZE - 1);

wire lastx1 = (x1 == X_SIZE - 1);
wire lasty1 = (y1 == Y_SIZE - 1);


reg a_valid = 0;
wire enter = ( ( state == OUTPUT ) && (state1 == OUTPUT) );
wire stop =  (pixel_pass == PASS);

wire valid = enter || a_valid;


// Even pixel generation
always @(posedge out_stream_aclk) begin
    if (!periph_resetn) begin
        if (switch) begin
            state <= JSTART;
        end else begin
            state <= MSTART;
        end
        
        x <= 0;
        y <= 0;
    end 

    else begin

        case(state)
            // julia
            JSTART: begin
                iter_count = 0;
                zr = -OFFSET_REAL + x * SCALE_REAL / X_SIZE;
                zi = -OFFSET_IMAG + y * SCALE_IMAG / Y_SIZE;
                state = JCHECK;
                c_re = regfile[0][31:16];
                c_im = regfile[0][15:0];
            end

            JCHECK: begin
                zr2 = (zr * zr) / SCALE_FACTOR;  
                zi2 = (zi * zi) / SCALE_FACTOR;  
                if (((zr2 + zi2) > limit) || iter_count == max_iteration - 1) begin
                    if (stop) begin
                        state = JCHECK; 
                    end else begin
                        iter_final = iter_count;
                        state = OUTPUT;
                    end
                end else begin
                    state = JITERATE;
                end
            end

            JITERATE: begin
                zr <= (zr2 - zi2) - c_re;
                zi <= (2 * zr * zi) / SCALE_FACTOR + c_im;
                iter_count <= iter_count + 1;
                state = JCHECK;
            end

            // mandelbrot
            MSTART: begin
                iter_count = 0;
                c_re = -OFFSET_REAL + x * SCALE_REAL / X_SIZE;
                c_im = -OFFSET_IMAG + y * SCALE_IMAG / Y_SIZE;
                zr = 0;
                zi = 0;
                state = MCHECK;
            end

            MCHECK: begin
                zr2 = (zr * zr) / SCALE_FACTOR;  
                zi2 = (zi * zi) / SCALE_FACTOR;  
                if (((zr2 + zi2) > limit) || iter_count == max_iteration - 1) begin
                    if (stop) begin
                        state = MCHECK; 
                    end else begin
                        iter_final = iter_count;
                        state = OUTPUT;
                    end
                end else begin
                    state = MITERATE;
                end
            end

            MITERATE: begin
                zr <= (zr2 - zi2) + c_re;
                zi <= (2 * zr * zi) / SCALE_FACTOR + c_im;
                iter_count <= iter_count + 1;
                state = MCHECK;
            end

            OUTPUT: begin
                if (out_stream_tready && (a_valid || enter)) begin
                    
                    if (lastx) begin
                        x <= 9'd0;
                        if (lasty) begin
                            y <= 8'd0;
                        end else begin
                            y <= y + 8'd1;
                        end
                    end 
                    else begin
                        x <= x + 9'd2;                  
                    end

                    if (switch) begin
                        state <= JSTART;
                    end 
                    else begin
                        state <= MSTART;
                    end

                end else begin
                    state  = OUTPUT;
                end
            end
            
            default: begin
                state <= MSTART;
            end

        endcase
    end
end
    


// Odd pixel generation
always @(posedge out_stream_aclk) begin
    if (!periph_resetn) begin
        if (switch) begin
            state1 <= JSTART;
        end else begin
            state1 <= MSTART;
        end
        
        x1 <= 1;
        y1 <= 0;
    end 
    else begin
        case(state1)

        // julia
        JSTART: begin
            iter_count1 = 0;
            zr1 = -OFFSET_REAL + x1 * SCALE_REAL / X_SIZE;
            zi1 = -OFFSET_IMAG + y1 * SCALE_IMAG / Y_SIZE;
            state1 = JCHECK;
            c_re1 = regfile[0][31:16];
            c_im1 = regfile[0][15:0];
        end

        JCHECK: begin
            zr21 = (zr1 * zr1) / SCALE_FACTOR;  
            zi21 = (zi1 * zi1) / SCALE_FACTOR;  
            if (((zr21 + zi21) > limit) || iter_count1 == max_iteration - 1) begin
                if (stop) begin
                    state1 = JCHECK;
                end else begin
                    iter_final1 = iter_count1;
                    state1 = OUTPUT;
                end 
            end else begin
                state1 = JITERATE;
            end
        end

        JITERATE: begin
            zr1 <= (zr21 - zi21) - c_re1;
            zi1 <= (2 * zr1 * zi1) / SCALE_FACTOR + c_im1;
            iter_count1 <= iter_count1 + 1;
            state1 = JCHECK;
        end

        // mandelbrot
        
        MSTART: begin
            iter_count1 <= 0;
            c_re1 = -OFFSET_REAL + x1 * SCALE_REAL / X_SIZE;
            c_im1 = -OFFSET_IMAG + y1 * SCALE_IMAG / Y_SIZE;
            zr1 = 0;
            zi1 = 0;
            state1 = MCHECK;
        end
        MCHECK: begin
            zr21 = (zr1 * zr1) / SCALE_FACTOR;  
            zi21 = (zi1 * zi1) / SCALE_FACTOR;  
            if (((zr21 + zi21) > (limit)) || iter_count1 == max_iteration - 1) begin
                if (stop) begin
                    state1 = MCHECK;
                end else begin
                    iter_final1 = iter_count1;
                    state1 = OUTPUT;
                end 
            end else begin
                state1 = MITERATE;
            end
        end

        MITERATE: begin
            zr1 <= (zr21 - zi21) + c_re1;
            zi1 <= (2 * zr1 * zi1) / SCALE_FACTOR + c_im1;
            iter_count1 <= iter_count1 + 1;
            state1 = MCHECK;
        end
        
    
        OUTPUT: begin
            if ((pixel_pass == PASS) && out_stream_tready) begin
                
                if (lastx1) begin
                    x1 <= 9'd1;
                    if (lasty1) begin
                        y1 <= 8'd0;
                    end else begin
                        y1 <= y1 + 8'd1;
                    end
                end 
                else begin
                    x1 <= x1 + 9'd2;       
                                
                end

                if (switch) begin
                    state1 <= JSTART;
                end 
                else begin
                    state1 <= MSTART;
                end

            end else begin
                state1  = OUTPUT;
            end
        end

            default: begin
                state1 <= MSTART;
            end
        endcase
    end
end



reg [23:0] data, data1; 

always @(*) begin
    if (iter_count == max_iteration-1) begin
        data =24'b0;
    end
    else begin
        data[23:16] = iter_final;  // Red component based on iteration count
        data[15:8] = (iter_final * regfile[1][15:8]);  // Green component
        data[7:0] = (iter_final *regfile[1][23:16]);  // Blue component        
    end
end

always @(*) begin
    if (iter_count1 == max_iteration-1) begin
        data1 =24'b0;
    end
    else begin
        data1[23:16] = iter_final1;  // Red component based on iteration count
        data1[15:8] = (iter_final1 * regfile[1][15:8]);  // Green component
        data1[7:0] = (iter_final1 *regfile[1][23:16]);  // Blue component    
    end
end


// pass
always @(posedge out_stream_aclk) begin // buffer, gen_stop, ready  
    case (pixel_pass)
        GEN: begin
            if (enter) begin
                a_valid <=1;
            end
            if (out_stream_tready && (a_valid||enter)) begin
                pixel_pass <= PASS;
            end
            else begin
                pixel_pass <= GEN;
            end
        end

        PASS: begin
            if(out_stream_tready) begin
                a_valid<=0;
                pixel_pass<=GEN;
            end
            else begin
                pixel_pass <= PASS;
            end
        end

        default: begin
            pixel_pass<= GEN;
        end

    endcase
end


wire [7:0] r, g, b;

// Simplified logic to assign r, g, b
assign r = (pixel_pass == GEN) ? data[23:16] : data1[23:16];
assign g = (pixel_pass == GEN) ? data[15:8]  : data1[15:8];
assign b = (pixel_pass == GEN) ? data[7:0]   : data1[7:0];


// wire [23:0] color;
// simulator pixel_simulator(
// .aclk(aclk),
// .aresetn(aresetn),
// .r(r),
// .g(g),
// .b(b),
// .simu_stream_tdata(color), 
// .valid(valid)
// );

 packer pixel_packer(    .aclk(out_stream_aclk),
                         .aresetn(periph_resetn),
                         .r(r), .g(g), .b(b),
                         .eol(lastx1 && lastx ), .in_stream_ready(ready), .valid(valid) , .sof(first),
                         .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                         .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                         .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

                    
endmodule