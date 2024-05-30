module mandelbrot_top(
    input clk,
    input reset,
    input out_stream_tready, // Assume input that indicates downstream readiness
    
    output  [31:0] out_stream_tdata,
    output  [3:0] out_stream_tkeep,
    output  out_stream_tlast,
    output  out_stream_tvalid,
    output [0:0] out_stream_tuser
);

    localparam X_SIZE = 640;
    localparam Y_SIZE = 480;

    localparam integer max_iteration = 255;
    localparam real re_max = 1;
    localparam real re_min = -2;
    localparam real im_max = 1.2;
    localparam real im_min = -1.2;

    localparam real SCALE_REAL = (re_max - re_min) / X_SIZE;
    localparam real SCALE_IMAG = (im_max - im_min) / Y_SIZE;
    localparam real OFFSET_REAL = re_min;
    localparam real OFFSET_IMAG = im_min;

    wire [9:0] x;
    wire [8:0] y;

    
    wire first = (x == 0) & (y == 0);
    wire lastx = (x == X_SIZE - 1);
    wire lasty = (y == Y_SIZE - 1);

    wire [31:0] cr, ci;
    wire [7:0] iter;
    wire [23:0] rgb;
    wire valid_gen, valid_iter, valid_color;

    coord_generator gen(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .cr(cr),
        .ci(ci),
        .ready_next_stage(valid_iter),
        .valid_out(valid_gen)
    );

    mandelbrot_iter iter_calc(
        .clk(clk),
        .reset(reset),
        .cr(cr),
        .ci(ci),
        .valid_in(valid_gen),
        .iter(iter),
        .valid_out(valid_iter)
    );

    color_mapper mapper(
        .clk(clk),
        .reset(reset),
        .iter(iter),
        .valid_in(valid_iter),
        .rgb(rgb),
        .valid_out(valid_color)
    );

    output_formatter formatter(
        .clk(clk),
        .reset(reset),
        .rgb(rgb),
        .valid_in(valid_color),
        .out_stream_tready(out_stream_tready),
        .out_stream_tdata(out_stream_tdata),
        .out_stream_tkeep(out_stream_tkeep),
        .out_stream_tlast(out_stream_tlast),
        .lastx(lastx),
        .lasty(lasty),
        .first(first),
        .out_stream_tvalid(out_stream_tvalid),
        .out_stream_tuser(out_stream_tuser)
    );

    // Simulation or visualization module
    simulator pixel_simulator(
        .aclk(clk),
        .aresetn(reset),
        .r(out_stream_tdata[31:24]), 
        .g(out_stream_tdata[23:16]), 
        .b(out_stream_tdata[15:8])
    );

endmodule
