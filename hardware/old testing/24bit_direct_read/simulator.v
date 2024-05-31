module simulator(
input           aclk,
input           aresetn,
input [7:0]     r,g,b,
output [23:0]   simu_stream_tdata
);

reg [23:0]      tdata;

always @(posedge aclk)begin
       if(aresetn)
          tdata = {r, g, b};
end      

assign simu_stream_tdata = tdata;

endmodule
