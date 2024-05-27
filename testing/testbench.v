`timescale 1ns / 1ps
module testbench;
    reg [9:0] x;
    reg [9:0] y;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;

    // Instantiate the test pattern module
    test_pattern uut (
        .x(x),
        .y(y),
        .r(r),
        .g(g),
        .b(b)
    );

    // VCD dump
    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, testbench);
    end

    // Generate pixel coordinates and drive inputs
    initial begin
        for (y = 0; y < 256; y = y + 1) begin
            for (x = 0; x < 256; x = x + 1) begin
                #10; // Delay for simulation
            end
        end
        $finish;
    end
endmodule
