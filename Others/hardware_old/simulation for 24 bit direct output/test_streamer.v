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
localparam RADIUS = 100; // Radius of the circle
localparam THICKNESS = 2; // Thickness of the circle outline

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire valid_int = 1'b1;

always @(posedge aclk) begin // 每个cycle遍历一个像素
    if (aresetn) begin
        if (out_stream_tready & valid_int) begin
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
wire [9:0] x_center = X_SIZE / 2;
wire [8:0] y_center = Y_SIZE / 2;

wire [19:0] dist_squared = (x - x_center) * (x - x_center) + (y - y_center) * (y - y_center);
wire [19:0] radius_outer_squared = (RADIUS * RADIUS);
wire [19:0] radius_inner_squared = (RADIUS - THICKNESS) * (RADIUS - THICKNESS);

wire in_circle_outline = (dist_squared >= radius_inner_squared) && (dist_squared <= radius_outer_squared);

assign r = in_circle_outline ? 8'd0 : 8'd255; // Black outline, white background
assign g = in_circle_outline ? 8'd0 : 8'd255; // Black outline, white background
assign b = in_circle_outline ? 8'd255 : 8'd255; // Black outline, white background

simulator pixel_simulator(      .aclk(aclk),
                                .aresetn(aresetn),
                                .r(r), .g(g), .b(b));

packer pixel_packer(    .aclk(aclk),
                        .aresetn(aresetn),
                        .r(r), .g(g), .b(b),
                        .eol(lastx), .in_stream_ready(out_stream_tready), .valid(valid_int), .sof(first),
                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

endmodule
