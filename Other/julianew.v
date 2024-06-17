module pixel_generator(
    input           out_stream_aclk,
    input           s_axi_lite_aclk,
    input           axi_resetn,
    input           periph_resetn,

    // Stream output
    output  [31:0]      out_stream_tdata,
    output              out_stream_tvalid,
    output              out_stream_tlast,
    output  [3:0]       out_stream_tkeep,
    output  [0:0]       out_stream_tuser,
    input               out_stream_tready,

    // AXI-Lite S
    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr,
    output reg                      s_axi_lite_arready,
    input                           s_axi_lite_arvalid,

    input [AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr,
    output reg                      s_axi_lite_awready,
    input                           s_axi_lite_awvalid,

    input                           s_axi_lite_bready,
    output reg [1:0]                s_axi_lite_bresp,
    output reg                      s_axi_lite_bvalid,

    output reg [31:0]               s_axi_lite_rdata,
    input                           s_axi_lite_rready,
    output reg [1:0]                s_axi_lite_rresp,
    output reg                      s_axi_lite_rvalid,

    input [31:0]                    s_axi_lite_wdata,
    output reg                      s_axi_lite_wready,
    input                           s_axi_lite_wvalid
);

parameter AXI_LITE_ADDR_WIDTH = 8;
parameter integer SCALE_FACTOR = 64; // Using 2^16 for fixed-point precision

localparam X_SIZE = 640;
localparam Y_SIZE = 480;
localparam MAX_ITERATIONS = 100;

localparam [1:0]
    START = 2'b00,
    ITERATE = 2'b01,
    OUTPUT = 2'b10;

localparam AWAIT_WADD_AND_DATA = 3'b000,
           AWAIT_WDATA = 3'b001,
           AWAIT_WADD = 3'b010,
           AWAIT_WRITE = 3'b100,
           AWAIT_RESP = 3'b101,
           AWAIT_RADD = 2'b00,
           AWAIT_FETCH = 2'b01,
           AWAIT_READ = 2'b10,
           AXI_OK = 2'b00,
           AXI_ERR = 2'b10;

reg [1:0] state = START;
reg [9:0] x = 0;
reg [8:0] y = 0;
reg [8:0] iter_count = 0;
reg [31:0]    regfile [REG_FILE_SIZE-1:0];

reg [AXI_LITE_ADDR_WIDTH-3:0] writeAddr, readAddr;
reg [31:0] readData, writeData;
reg [1:0] readState = AWAIT_RADD;
reg [2:0] writeState = AWAIT_WADD_AND_DATA;

// State machine for pixel processing
always @(posedge out_stream_aclk or negedge periph_resetn) begin
    if (!periph_resetn) begin
        x <= 0;
        y <= 0;
        iter_count <= 0;
        state <= START;
        out_stream_tvalid <= 0;
        out_stream_tlast <= 0;
    end else begin
        case (state)
            START: begin
                iter_count <= 0;
                state <= ITERATE;
            end
            ITERATE: begin
                if (iter_count < MAX_ITERATIONS) begin
                    iter_count <= iter_count + 1;
                end else begin
                    state <= OUTPUT;
                end
            end
            OUTPUT: begin
                out_stream_tdata <= {8{compute_julia(x, y, iter_count)}};
                out_stream_tvalid <= 1;
                out_stream_tlast <= (x == X_SIZE - 1) && (y == Y_SIZE - 1);
                if (out_stream_tready) begin
                    if (x == X_SIZE - 1 && y == Y_SIZE - 1) begin
                        x <= 0;
                        y <= 0;
                        state <= START;
                    end else begin
                        if (x == X_SIZE - 1) begin
                            x <= 0;
                            y <= y + 1;
                        end else begin
                            x <= x + 1;
                        end
                        state <= START; // Move to start to process the next pixel
                    end
                end
            end
        endcase
    end
end

function [23:0] compute_julia(input [9:0] px, input [8:0] py, input [8:0] iter);
    integer zr, zi, zr2, zi2;
    integer c_re = -0.835 * SCALE_FACTOR;
    integer c_im = -0.2321 * SCALE_FACTOR;
    begin
        zr = -1.5 * SCALE_FACTOR + px * ((3.0 * SCALE_FACTOR) / X_SIZE);
        zi = -1.2 * SCALE_FACTOR + py * ((2.4 * SCALE_FACTOR) / Y_SIZE);
        for (int i = 0; i < iter; i++) begin
            zr2 = (zr * zr) / SCALE_FACTOR;
            zi2 = (zi * zi) / SCALE_FACTOR;
            if (zr2 + zi2 > 4 * SCALE_FACTOR) break;
            zi = 2 * zr * zi / SCALE_FACTOR + c_im;
            zr = zr2 - zi2 + c_re;
        end
        compute_julia = {8'hFF, (iter * 2) % 256, (iter * 3) % 256};
    end
endfunction

// AXI Lite Interface for configuration...
always @(posedge s_axi_lite_aclk) begin
    if (!axi_resetn) begin
        s_axi_lite_arready <= 0;
        s_axi_lite_awready <= 0;
        s_axi_lite_bvalid <= 0;
        s_axi_lite_rvalid <= 0;
        s_axi_lite_wready <= 0;
        readState <= AWAIT_RADD;
        writeState <= AWAIT_WADD_AND_DATA;
    end else begin
        // Write state machine
        case (writeState)
            AWAIT_WADD_AND_DATA: begin
                if (s_axi_lite_awvalid && s_axi_lite_wvalid) begin
                    writeAddr <= s_axi_lite_awaddr[AXI_LITE_ADDR_WIDTH-3:0];
                    writeData <= s_axi_lite_wdata;
                    s_axi_lite_awready <= 1;
                    s_axi_lite_wready <= 1;
                    writeState <= AWAIT_WRITE;
                end
            end
            AWAIT_WRITE: begin
                if (s_axi_lite_awready && s_axi_lite_wready) begin
                    regfile[writeAddr] <= writeData;
                    s_axi_lite_awready <= 0;
                    s_axi_lite_wready <= 0;
                    writeState <= AWAIT_RESP;
                end
            end
            AWAIT_RESP: begin
                if (s_axi_lite_bready) begin
                    s_axi_lite_bresp <= AXI_OK;
                    s_axi_lite_bvalid <= 1;
                    writeState <= AWAIT_WADD_AND_DATA;
                end
            end
        endcase

        // Read state machine
        case (readState)
            AWAIT_RADD: begin
                if (s_axi_lite_arvalid) begin
                    readAddr <= s_axi_lite_araddr[AXI_LITE_ADDR_WIDTH-3:0];
                    s_axi_lite_arready <= 1;
                    readState <= AWAIT_FETCH;
                end
            end
            AWAIT_FETCH: begin
                if (s_axi_lite_arready) begin
                    readData <= regfile[readAddr];
                    s_axi_lite_arready <= 0;
                    readState <= AWAIT_READ;
                end
            end
            AWAIT_READ: begin
                if (s_axi_lite_rready) begin
                    s_axi_lite_rdata <= readData;
                    s_axi_lite_rresp <= AXI_OK;
                    s_axi_lite_rvalid <= 1;
                    readState <= AWAIT_RADD;
                end
            end
        endcase
    end
end

endmodule