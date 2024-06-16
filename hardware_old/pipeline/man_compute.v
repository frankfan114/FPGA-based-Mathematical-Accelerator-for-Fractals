module man_compute(
    input aclk,
    input aresetn,
    input [9:0] px,
    input [8:0] py,
    input integer max_iteration,

    input real cr,
    input real ci,
    input real zr,
    input real zi,
    input real zr2,
    input real zi2,

    input integer i,

    output reg [23:0] compute_mandelbrot
);

    always_comb() begin
            cr = OFFSET_REAL + px * SCALE_REAL;
            ci = OFFSET_IMAG + py * SCALE_IMAG;
            zr = 0;
            zi = 0;
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        



    end






    
endmodule