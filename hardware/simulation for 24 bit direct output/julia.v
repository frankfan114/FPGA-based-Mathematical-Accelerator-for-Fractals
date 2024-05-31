module test_streamer (
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

// Julia parameters
localparam integer max_iteration = 255;

// width/height = 640/480 = 4/3
// imaginary within [-1.5: 1.5], with total range of 3
// hence real within [-2: 2], with total range of 4

localparam real SCALE_REAL = 4.0 / X_SIZE;
localparam real SCALE_IMAG = 3.0 / Y_SIZE;
localparam real OFFSET_REAL = -2.0; // Real offset to map [-2, 2] in complex plane
localparam real OFFSET_IMAG = -1.5; // Imaginary offset to map [-1.5, 1.5] in complex plane
// Complex value for Julia set, changeable input 
localparam real C_REAL = -0.835;
localparam real C_IMAG = -0.2321;

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

function [23:0] compute_julia;
    input [9:0] px;
    input [8:0] py;
    real zr, zi, zr2, zi2;
    integer i;
    reg [15:0] density;
    reg escape; // Flag to control when to stop iterating
    reg [7:0] red, green, blue;
    begin
        zr = OFFSET_REAL + px * SCALE_REAL;
        zi = OFFSET_IMAG + py * SCALE_IMAG;
        density = 0;
        escape = 0; // Initialize the escape flag to false
        for (i = 0; i < max_iteration && !escape; i = i + 1) begin
            zr2 = zr * zr;
            zi2 = zi * zi;
            if (zr2 + zi2 > 4.0) begin
                escape = 1; // Set the escape flag to true to stop iterating
            end else begin
                zi = 2 * zr * zi + C_IMAG;
                zr = zr2 - zi2 + C_REAL;
                density = density + 1; // Increment density for paths
            end
        end

        // Simple non-linear color mapping based on density
        if (density == max_iteration) begin
            red = 0;
            green = 0;
            blue = 0;
        end else begin
            red = (density * density) % 256; // Red component
            green = (density * density * density) % 256; // Green component
            blue = (density) % 256; // Blue component
        end
        compute_julia = {red, green, blue};
    end
endfunction

always @(*) begin
    {out_stream_tdata[31:24], out_stream_tdata[23:16], out_stream_tdata[15:8]} = compute_julia(x, y);
    out_stream_tdata[7:0] = 8'd0; // Padding the LSB of data with zero
    out_stream_tkeep = 4'b1111;
    out_stream_tlast = lastx & lasty;
    out_stream_tuser = first;
end

simulator pixel_simulator(
    .aclk(aclk),
    .aresetn(aresetn),
    .r(out_stream_tdata[31:24]),
    .g(out_stream_tdata[23:16]),
    .b(out_stream_tdata[15:8])
);

endmodule