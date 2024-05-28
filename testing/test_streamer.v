module test_streamer(
input           aclk,
input           aresetn,

output [31:0]   out_stream_tdata,
output [3:0]    out_stream_tkeep,
output          out_stream_tlast,
input           out_stream_tready,
output          out_stream_tvalid,
output [0:0]    out_stream_tuser );

localparam X_SIZE = 640;
localparam Y_SIZE = 480;

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire valid_int = 1'b1;

always @(posedge aclk) begin
    if (aresetn) begin
        if (ready & valid_int) begin
            if (lastx) begin
                x <= 9'd0;
                if (lasty) begin
                    y <= 9'd0;
                end
                else begin
                    y <= y + 9'd1;
                end
            end
            else x <= x + 9'd1;
        end
    end
    else begin
        x <= 0;
        y <= 0;
    end
end

wire [7:0] r, g, b;
assign r = x[7:0];
assign g = x[6:0]+y[6:0];
assign b = y[7:0];

packer pixel_packer(    .aclk(aclk),
                        .aresetn(aresetn),
                        .r(r), .g(g), .b(b),
                        .eol(lastx), .in_stream_ready(ready), .valid(valid_int), .sof(first),
                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

 
endmodule