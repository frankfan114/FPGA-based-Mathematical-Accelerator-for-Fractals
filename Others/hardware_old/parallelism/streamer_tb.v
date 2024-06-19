`timescale 1ns / 1ps
module pixel_generator_tb;

reg clk = 0;
reg rst = 0;
always #5 clk = !clk;

wire [31:0] data;
wire [3:0] keep;
wire last, valid, user;

pixel_generator uut (
    .out_stream_aclk(clk),
    .s_axi_lite_aclk(clk),
    .axi_resetn(rst),
    .periph_resetn(rst),
    .out_stream_tdata(data),
    .out_stream_tkeep(keep),
    .out_stream_tlast(last),
    .out_stream_tready(1'b1),
    .out_stream_tvalid(valid),
    .out_stream_tuser(user),
    .s_axi_lite_araddr(8'b0),
    .s_axi_lite_arready(),
    .s_axi_lite_arvalid(1'b0),
    .s_axi_lite_awaddr(8'b0),
    .s_axi_lite_awready(),
    .s_axi_lite_awvalid(1'b0),
    .s_axi_lite_bready(1'b0),
    .s_axi_lite_bresp(),
    .s_axi_lite_bvalid(),
    .s_axi_lite_rdata(),
    .s_axi_lite_rready(1'b0),
    .s_axi_lite_rresp(),
    .s_axi_lite_rvalid(),
    .s_axi_lite_wdata(32'b0),
    .s_axi_lite_wready(),
    .s_axi_lite_wvalid(1'b0)
);

// Assigning the stream control signals in the testbench
// assign valid = 1'b1;
assign keep = 4'b1111;
assign last = (uut.x == (uut.X_SIZE - 1)) && (uut.y == (uut.Y_SIZE - 1));
assign user = (uut.x == 0) && (uut.y == 0);

initial begin
    rst = 0;
    #20 rst = 1;
    $dumpfile("test.vcd");
    $dumpvars(0, pixel_generator_tb);
    #20000000 $finish;
end

endmodule