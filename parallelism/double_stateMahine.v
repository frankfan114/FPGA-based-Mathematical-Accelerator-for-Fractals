
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

initial begin
   regfile[0] = 0;
end

localparam max_iteration = 100;
localparam color1 =3;
localparam color2= 5;
parameter SCALE_FACTOR = 256;
localparam X_SIZE = 640;
localparam Y_SIZE = 480;

localparam  SCALE_REAL = 768;
localparam  SCALE_IMAG = 614;
localparam  OFFSET_REAL = -384;
localparam  OFFSET_IMAG = -307;

localparam [2:0]
    MSTART = 3'b000,
    MITERATE = 3'b001,
    MOUTPUT = 3'b010,
    JSTART = 3'b011,
    JITERATE = 3'b100,
    JOUTPUT = 3'b101;

reg [2:0]  state = MSTART; 
wire switch = (regfile[0] == 1);
reg [15:0] x; 
reg [15:0] y;
reg [7:0] iter_count;

reg signed [31:0] zr, zi, zr2, zi2, c_im, c_re;
wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);


always @(posedge out_stream_aclk) begin

    case(state)
        JSTART: begin
            if (periph_resetn) begin
                iter_count <= 0;
                zr <= OFFSET_REAL + x * SCALE_REAL/ X_SIZE;
                zi <= OFFSET_IMAG + y * SCALE_IMAG/ Y_SIZE;
                state <= JITERATE;
            end
            else begin
                x <= 0;
                y <= 0;

                if(switch) begin
                   state <= JSTART;
                end    
                else begin
                   state <= MSTART;
                end
            end
        end

        JITERATE: begin
            if (periph_resetn) begin
                zr2 = (zr * zr) / SCALE_FACTOR;  
                zi2 = (zi * zi) / SCALE_FACTOR;  

                if (((zr2 + zi2) > (4*SCALE_FACTOR*SCALE_FACTOR))   || iter_count == max_iteration-1) begin
                    iter_count <= iter_count+1;
                    state <= JOUTPUT;                  
                end

                else begin
                    zr <= (zr2 - zi2) -213;
                    zi <= (2 * zr * zi) / SCALE_FACTOR -59;
                    iter_count <= iter_count + 1;
                    state <= JITERATE;
                end
            end
            else begin
                x <= 0;
                y <= 0;

                if(switch) begin
                   state <= JSTART;
                end    
                else begin
                   state <= MSTART;
                end
            end
        end

        JOUTPUT: begin
        if (periph_resetn) begin
            iter_count <= 0;
            zr <= 0;
            zi <= 0;
            if (lastx) begin
                x <= 16'd0;
                if (lasty) begin
                    y <= 16'd0;
                end
                else begin
                    y <= y + 16'd1;
                end
            end
            else x <= x + 16'd1;
            if(out_stream_tready)begin
                state <= JSTART; // Move to start to process the next pixel if 
            end
        end
            else begin
                x <= 0;
                y <= 0;

                if(switch) begin
                   state <= JSTART;
                end    
                else begin
                   state <= MSTART;
                end
            end
        end

    
    // mandelbrot 
        MSTART: begin
            if (periph_resetn) begin
                c_re = OFFSET_REAL + x * SCALE_REAL / X_SIZE;
                c_im = OFFSET_IMAG + y * SCALE_IMAG / Y_SIZE;
                zr <= 0; 
                zi <= 0; 
                state <= MITERATE;
            end

            else begin
                x <= 0;
                y <= 0;
                
                if(switch)begin
                    state <= JSTART;
                end
                else begin
                    state <= MSTART;
                end
            end
        end

        MITERATE: begin
            if (periph_resetn) begin
                zr2 = (zr * zr) / SCALE_FACTOR;  
                zi2 = (zi * zi) / SCALE_FACTOR;  

                if (((zr2 + zi2) > (4*SCALE_FACTOR*SCALE_FACTOR))   || iter_count == max_iteration-1) begin
                    iter_count <= iter_count+1;
                    state <= MOUTPUT;
                    
                end 
                else begin
                    zr <= (zr2 - zi2) + c_re;
                    zi <= (2 * zr * zi) / SCALE_FACTOR + c_im;
                    iter_count <= iter_count + 1;
                    state <= MITERATE;
                end
            end
             else begin
                x <= 0;
                y <= 0;
                
                if(switch)begin
                    state <= JSTART;
                end
                else begin
                    state <= MSTART;
                end
            end
        end

        MOUTPUT: begin
        if (periph_resetn) begin
            iter_count <= 0;
            zr <= 0;
            zi <= 0;
            if (lastx) begin
                x <= 16'd0;
                if (lasty) begin
                    y <= 16'd0;
                end
                else begin
                    y <= y + 16'd1;
                end
            end
            else x <= x + 16'd1;
            if(out_stream_tready)begin
                state <= MSTART; // Move to start to process the next pixel if 
            end
        end
            else begin
                x <= 0;
                y <= 0;
                
                if(switch)begin
                    state <= JSTART;
                end
                else begin
                    state <= MSTART;
                end
            end
        end

        default: begin
            state <= MSTART;
        end
    endcase
end

wire Mvalid = (state == MOUTPUT);
// wire Jvalid = (state == JOUTPUT);

reg [23:0] data; 

always @(*) begin
    if (iter_count == max_iteration) begin
        data[23:16] = 0;
        data[15:8]  = 0;
        data[7:0]  = 0; 
    end
    else begin
        data[23:16] = iter_count;  // Red component based on iteration count
        data[15:8] = iter_count;  // Green component
        data[7:0] = iter_count;  // Blue component
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
 .valid(Mvalid)
 );

//    packer pixel_packer(    .aclk(out_stream_aclk),
//                        .aresetn(periph_resetn),
//                        .r(r), .g(g), .b(b),
//                        .eol(lastx), .in_stream_ready(ready), .valid(Jvalid || Mvalid), .sof(first),
//                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
//                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
//                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

                       
endmodule