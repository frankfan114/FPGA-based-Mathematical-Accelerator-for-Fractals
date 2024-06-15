module top_level(
    input           clk,              // Common clock for all modules
    input           resetn,           // Common reset for all modules

    // Assuming external interfaces for data output
    output [31:0]   stream_data_out,
    output [3:0]    stream_keep_out,
    output          stream_last_out,
    output          stream_valid_out,
    input           stream_ready_in
);

// Parameters
parameter NUM_GEN = 4;  // Number of pixel generators and packers
parameter IMG_WIDTH = 640;
parameter SEG_WIDTH = IMG_WIDTH / NUM_GEN;  // Width handled by each generator

// Wire definitions for interconnections
wire [31:0]   gen_data[NUM_GEN-1:0];
wire [3:0]    gen_keep[NUM_GEN-1:0];
wire          gen_last[NUM_GEN-1:0];
wire          gen_valid[NUM_GEN-1:0];
wire          gen_ready[NUM_GEN-1:0];

genvar i;
generate
    for (i = 0; i < NUM_GEN; i++) begin : gen_packer_block
        // Pixel Generator Instance
        pixel_generator pg(
            .out_stream_aclk(clk),
            .axi_resetn(resetn),
            .periph_resetn(resetn),
            .out_stream_tdata(gen_data[i]),
            .out_stream_tkeep(gen_keep[i]),
            .out_stream_tlast(gen_last[i]),
            .out_stream_tready(gen_ready[i]),
            .out_stream_tvalid(gen_valid[i]),
            .out_stream_tuser(1'b0)  // Simplified for example
        );

        // Packer Instance
        packer pack(
            .aclk(clk),
            .aresetn(resetn),
            .r(gen_data[i][23:16]),
            .g(gen_data[i][15:8]),
            .b(gen_data[i][7:0]),
            .eol(gen_last[i]),
            .in_stream_ready(gen_ready[i]),
            .valid(gen_valid[i]),
            .sof(i == 0),  // Start of frame only for first generator
            .out_stream_tdata(stream_data_out),
            .out_stream_tkeep(stream_keep_out),
            .out_stream_tlast(stream_last_out),
            .out_stream_tready(stream_ready_in),
            .out_stream_tvalid(stream_valid_out),
            .out_stream_tuser()  // Assuming simplified handling
        );
    end
endgenerate

// Example logic to manage the output from packers (needs customization)
// This might include multiplexing the output, combining data, or handling synchronization.

endmodule
