module test_streamer(
    input           aclk,
    input           aresetn,

    output reg [31:0]   out_stream_tdata,
    output reg [3:0]    out_stream_tkeep,
    output reg          out_stream_tlast,
    input               out_stream_tready,
    output reg          out_stream_tvalid,
    output reg [0:0]    out_stream_tuser
);

localparam X_SIZE = 640;
localparam Y_SIZE = 480;

// Mandelbrot parameters
localparam integer max_iteration = 255;

// Scaling factors for the complex plane
localparam real SCALE_REAL = 3.0 / X_SIZE;
localparam real SCALE_IMAG = 2.4 / Y_SIZE;
localparam real OFFSET_REAL = -2.0; // Real offset to map [-2, 1] in complex plane
localparam real OFFSET_IMAG = -1.2; // Imaginary offset to map [-1.2, 1.2] in complex plane

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        x <= 0;
        y <= 0;
        out_stream_tvalid <= 1'b0;
    end
    else begin
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
    end
end

// Function to compute the Mandelbrot set and return RGB color
function [23:0] compute_mandelbrot;
    input [9:0] px;
    input [8:0] py;
    real cr, ci, zr, zi, zr2, zi2;
    integer i;
    begin
        cr = OFFSET_REAL + px * SCALE_REAL;
        ci = OFFSET_IMAG + py * SCALE_IMAG;
        zr = 0;
        zi = 0;
        for (i = 0; i < max_iteration; i = i + 1) begin
            zr2 = zr * zr;
            zi2 = zi * zi;
            if (zr2 + zi2 > 4.0) begin
                // Map the iteration count to RGB (simple grayscale mapping for now)
                compute_mandelbrot = {i[7:0], i[7:0], i[7:0]};
                i = max_iteration; // Exit the loop early
            end
            else begin
                zi = 2 * zr * zi + ci;
                zr = zr2 - zi2 + cr;
            end
        end
        // If max_iteration is reached, the point is in the Mandelbrot set (black)
        if (i == max_iteration) begin
            compute_mandelbrot = 24'h000000;
        end
    end
endfunction

always @(*) begin
    {out_stream_tdata[31:24], out_stream_tdata[23:16], out_stream_tdata[15:8]} = compute_mandelbrot(x, y);
    out_stream_tdata[7:0] = 8'd0; // Padding the LSB of data with zero
    out_stream_tkeep = 4'b1111;   // Assuming all bytes are valid
    out_stream_tlast = lastx & lasty; // End of frame
    out_stream_tuser = first;     // Indicate the first pixel
end

simulator pixel_simulator(
    .aclk(aclk),
    .aresetn(aresetn),
    .r(out_stream_tdata[31:24]), 
    .g(out_stream_tdata[23:16]), 
    .b(out_stream_tdata[15:8])
);

endmodule



// module test_streamer(
// input           aclk,
// input           aresetn,

// output [31:0]   out_stream_tdata,
// output [3:0]    out_stream_tkeep,
// output          out_stream_tlast,
// input           out_stream_tready,
// output          out_stream_tvalid,
// output [0:0]    out_stream_tuser );

// localparam X_SIZE = 640;
// localparam Y_SIZE = 480;
// localparam INITIAL_RADIUS = 100; // Initial radius of the original circle
// localparam THICKNESS = 2; // Thickness of the circle outline

// reg [9:0] x;
// reg [8:0] y;

// wire first = (x == 0) & (y==0);
// wire lastx = (x == X_SIZE - 1);
// wire lasty = (y == Y_SIZE - 1);

// wire valid_int = 1'b1;

// always @(posedge aclk) begin // 每个cycle遍历一个像素
//     if (aresetn) begin
//         if (out_stream_tready & valid_int) begin
//             if (lastx) begin
//                 x <= 9'd0;
//                 if (lasty) begin
//                     y <= 9'd0;
//                 end
//                 else begin
//                     y <= y + 9'd1;
//                 end
//             end
//             else x <= x + 9'd1;
//         end
//     end
//     else begin
//         x <= 0;
//         y <= 0;
//     end
// end

// wire [7:0] r, g, b;
// wire [9:0] x_center = X_SIZE / 2;
// wire [8:0] y_center = Y_SIZE / 2;

// integer i;
// reg [19:0] dist_squared;
// reg [19:0] radius_outer_squared;
// reg [19:0] radius_inner_squared;
// reg [19:0] x_center_current;
// reg [8:0] y_center_current;
// reg [19:0] current_radius;
// reg in_any_circle_outline;
// reg stop_drawing;

// always @* begin
//     in_any_circle_outline = 0;
//     x_center_current = x_center;
//     y_center_current = y_center;
//     current_radius = INITIAL_RADIUS;
//     stop_drawing = 0;

//     for (i = 0; i < 10 && !stop_drawing; i = i + 1) begin
//         radius_outer_squared = current_radius * current_radius;
//         radius_inner_squared = (current_radius - THICKNESS) * (current_radius - THICKNESS);
//         dist_squared = (x - x_center_current) * (x - x_center_current) + (y - y_center_current) * (y - y_center_current);

//         if ((dist_squared >= radius_inner_squared) && (dist_squared <= radius_outer_squared)) begin
//             in_any_circle_outline = 1;
//         end

//         // Calculate the center for the next smaller circle
//         x_center_current = x_center_current + current_radius;
//         current_radius = (current_radius * 7) / 8;

//         // Check if the next circle center is out of bounds
//         if (x_center_current >= X_SIZE) begin
//             stop_drawing = 1;
//         end
//     end
// end

// assign r = in_any_circle_outline ? 8'd0 : 8'd255; // Black outline, white background
// assign g = in_any_circle_outline ? 8'd0 : 8'd255; // Black outline, white background
// assign b = in_any_circle_outline ? 8'd0 : 8'd255; // Black outline, white background

// simulator pixel_simulator(      .aclk(aclk),
//                                 .aresetn(aresetn),
//                                 .r(r), .g(g), .b(b));

// packer pixel_packer(    .aclk(aclk),
//                         .aresetn(aresetn),
//                         .r(r), .g(g), .b(b),
//                         .eol(lastx), .in_stream_ready(out_stream_tready), .valid(valid_int), .sof(first),
//                         .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
//                         .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
//                         .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

// endmodule