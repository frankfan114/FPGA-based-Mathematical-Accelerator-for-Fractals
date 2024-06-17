module mandelbrot_processor(
    input clk,
    input reset,
    input start,  // Signal to start the computation
    input [9:0] px,
    input [8:0] py,
    output reg [23:0] rgb_out,
    output reg done  // Signal when computation is complete
);

localparam IDLE = 0, COMPUTE = 1, DONE = 2;
integer state = IDLE;
integer i;
real cr, ci, zr, zi, zr2, zi2;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        rgb_out <= 0;
        done <= 0;
    end else begin
        case (state)
            IDLE:
                if (start) begin
                    cr <= OFFSET_REAL + px * SCALE_REAL;
                    ci <= OFFSET_IMAG + py * SCALE_IMAG;
                    zr <= 0;
                    zi <= 0;
                    i <= 0;
                    state <= COMPUTE;
                end
            COMPUTE:
                if (i < max_iteration) begin
                    zr2 <= zr * zr;
                    zi2 <= zi * zi;
                    if (zr2 + zi2 > 4.0) begin
                        rgb_out <= palette(i);
                        state <= DONE;
                    end else begin
                        zi <= 2 * zr * zi + ci;
                        zr <= zr2 - zi2 + cr;
                        i <= i + 1;
                    end
                end else begin
                    rgb_out <= 24'h000000; // Max iterations reached, pixel is in the set
                    state <= DONE;
                end
            DONE:
                begin
                    done <= 1;
                    state <= IDLE;
                end
        endcase
    end
end

// Example function to calculate color based on iterations
function [23:0] palette(input integer idx);
begin
    palette = {8'h00, idx[7:0], 8'h00}; // Simplified example
end
endfunction

endmodule
