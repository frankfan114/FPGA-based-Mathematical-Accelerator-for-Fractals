module output_formatter(
    input clk,
    input reset,
    input [23:0] rgb,
    input valid_in,
    output reg [31:0] stream_data,
    output reg  out_stream_valid,
    input reg out_stream_ready,
    output reg [3:0] out_stream_tkeep,
    output reg out_stream_tlast,
    output reg [0:0] out_stream_tuser,
    input wire lastx,
    input wire lasty,
    input wire first,

);
    // Output formatting logic
    always @(posedge clk) begin
        if (!reset) begin
            stream_data <= 0;
            stream_valid <= 0;
        end else if (valid_in && stream_ready) begin
            stream_data <= {rgb, 8'h00}; // Assuming last 8 bits are padding
            stream_valid <= 1;
        end else if (!stream_ready) begin
            stream_valid <= 0;
        end
    end
endmodule
