module test_streamer(
    input           aclk,
    input           aresetn, // Active low reset

    output reg [31:0]   out_stream_tdata,
    output reg [3:0]    out_stream_tkeep,
    output reg          out_stream_tlast,
    input               out_stream_tready,
    output reg          out_stream_tvalid, // enable output data
    output reg [0:0]    out_stream_tuser
);

localparam X_SIZE = 640;
localparam Y_SIZE = 480;

// Mandelbrot parameters
localparam integer max_iteration = 255;

// width/height = 640/480 = 4/3
// imaginary within [-1.5: 1.5], with total range of 3
// hence real within [-3: 1], with total range of 4

localparam real SCALE_REAL = 4.0 / X_SIZE;
localparam real SCALE_IMAG = 3.0 / Y_SIZE;
localparam real OFFSET_REAL = -3.0; // Real offset to map [-3, 1] in complex plane
localparam real OFFSET_IMAG = -1.5; // Imaginary offset to map [-1.5, 1.5] in complex plane

reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y == 0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

always @(posedge aclk) begin // iterate one pixel per cycle
    if (aresetn) begin
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
    else begin
        x <= 0;
        y <= 0;
        out_stream_tvalid <= 1'b0;
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

function [23:0] compute_mandelbrot;
    input [9:0] px;
    input [8:0] py;
    real cr, ci, zr, zi, zr2, zi2;
    integer i;
    reg [15:0] density;
    reg escape; // Flag to control when to stop iterating
    begin
        cr = OFFSET_REAL + px * SCALE_REAL;
        ci = OFFSET_IMAG + py * SCALE_IMAG;
        zr = 0;
        zi = 0;
        density = 0;
        escape = 0; // Initialize the escape flag to false
        for (i = 0; i < max_iteration && !escape; i = i + 1) begin
            zr2 = zr * zr;
            zi2 = zi * zi;
            if (zr2 + zi2 > 4.0) begin
                escape = 1; // Set the escape flag to true to stop iterating
            end else begin
                zi = 2 * zr * zi + ci;
                zr = zr2 - zi2 + cr;
                density = density + 1; // Increment density for paths
            end
        end
        // Simple non-linear color mapping based on density
        compute_mandelbrot[23:16] = (density * density) % 256;  // Red component
        compute_mandelbrot[15:8]  = (density * density * density) % 256; // Green component
        compute_mandelbrot[7:0]   = (density) % 256;  // Blue component
    end
endfunction


// Function to generate color based on iteration count
function [23:0] palette;
    input [7:0] iter;
    reg [7:0] r, g, b;
    begin
        // Example color palette
        r = iter * 1; // Red component
        g = iter * 2; // Green component
        b = iter * 3; // Blue component
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

// combine 8-bit R, G, B values into 24-bit color
simulator pixel_simulator(
    .aclk(aclk),
    .aresetn(aresetn),
    .r(out_stream_tdata[31:24]), 
    .g(out_stream_tdata[23:16]), 
    .b(out_stream_tdata[15:8])
);

endmodule