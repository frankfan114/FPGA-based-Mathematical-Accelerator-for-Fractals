module test_pattern (
    input wire [9:0] x,       // x coordinate
    input wire [9:0] y,       // y coordinate
    output reg [7:0] r,       // red component
    output reg [7:0] g,       // green component
    output reg [7:0] b        // blue component
);
    always @(*) begin
        // Simple test pattern: horizontal gradient
        r = x[7:0];
        g = y[7:0];
        b = (x + y) / 2;
    end
endmodule
