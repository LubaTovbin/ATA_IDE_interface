module ocs_clk (
  input  clk_en,
  output o_clk  
  );
`include "steed.vh"
reg clk_r;

always begin
  clk_r = 1'b0;
  #`HALF_CYCLE;
  clk_r = 1'b1;
  #`HALF_CYCLE;
  end
  //assign o_clk = (clk_en) ? 1'b0 : clk_r;
  assign o_clk = clk_r;
endmodule