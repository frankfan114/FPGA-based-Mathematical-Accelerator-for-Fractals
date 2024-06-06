// File: fp_mult.v
module fp_mult(
    input clk,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result // Output is 'reg' because it is driven by a procedural block
);
    // Assuming a simple multiplication for illustrative purposes
    always @(posedge clk) begin
        result <= a * b; // Real FP multiplication would be more complex
    end
endmodule
