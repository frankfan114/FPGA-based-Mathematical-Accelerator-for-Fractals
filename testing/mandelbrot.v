module mandelbrot(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [31:0] real_min,
    input wire [31:0] real_max,
    input wire [31:0] imag_min,
    input wire [31:0] imag_max,
    input wire [31:0] width,
    input wire [31:0] height,
    input wire [31:0] max_iter,
    output reg [23:0] pixel_data,
    output reg valid,
    output reg done
);

    // State machine states
    typedef enum reg [2:0] {IDLE, INIT, CALCULATE, OUTPUT, FINISH} state_t;
    state_t state;

    // Variables
    reg signed [31:0] x, y;
    reg signed [63:0] real, imag, real_c, imag_c, real_temp;
    reg [31:0] iter;

    // State machine logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            valid <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        x <= 0;
                        y <= 0;
                        state <= INIT;
                    end
                end
                INIT: begin
                    real_c <= real_min + (real_max - real_min) * x / (width - 1);
                    imag_c <= imag_min + (imag_max - imag_min) * y / (height - 1);
                    real <= 0;
                    imag <= 0;
                    iter <= 0;
                    state <= CALCULATE;
                end
                CALCULATE: begin
                    if (iter < max_iter && (real*real + imag*imag) < (4 << 32)) begin
                        real_temp <= real*real - imag*imag + real_c;
                        imag <= 2*real*imag + imag_c;
                        real <= real_temp;
                        iter <= iter + 1;
                    end else begin
                        state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    if (iter == max_iter) begin
                        pixel_data <= 24'h000000; // Black
                    end else begin
                        // Simple color mapping
                        pixel_data <= {iter[7:0], iter[7:0], iter[7:0]};
                    end
                    valid <= 1;
                    state <= FINISH;
                end
                FINISH: begin
                    if (x < width - 1) begin
                        x <= x + 1;
                        state <= INIT;
                    end else if (y < height - 1) begin
                        x <= 0;
                        y <= y + 1;
                        state <= INIT;
                    end else begin
                        done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule