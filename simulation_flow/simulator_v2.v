module simulator(
input           aclk,
input           aresetn,
input [7:0]     r,g,b,
//
input valid,

output [23:0]   simu_stream_tdata
);

reg [23:0]      tdata;

// always @(posedge aclk)begin
//        if(aresetn)
//           tdata = {r, g, b};
// end      

always @ (*) begin
    if(valid)
        tdata = {r, g, b};
    else
        tdata = 24'b0;
end

assign simu_stream_tdata = tdata;

endmodule
