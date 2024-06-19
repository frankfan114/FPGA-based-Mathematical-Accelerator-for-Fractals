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
                // Map the iteration count to RGB using a color palette
                compute_mandelbrot = palette(i);
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

// Function to generate color based on iteration count
function [23:0] palette;
    input [7:0] iter;
    reg [7:0] r, g, b;
    begin
        // Example color palette
        r = iter; // Red component
        g = iter * 2; // Green component
        b = 255 - iter; // Blue component
        palette = {r, g, b};
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