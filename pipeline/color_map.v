module color_mapper(
    input clk,
    input reset,
    input [7:0] iter,
    input valid_in,
    output reg [23:0] rgb,
    output reg valid_out
);
    // Mapping logic
    always @(posedge clk) begin
        if (!reset) begin
            rgb <= 24'h000000;
            valid_out <= 0;
        end else if (valid_in) begin
            rgb <= palette(iter);
            valid_out <= 1;
        end
    end
endmodule
