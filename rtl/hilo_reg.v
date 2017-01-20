`include "define.v"
module hilo_reg(
                 //input 
                 clk,
                 rst,
                 we,
                 hi_i,
                 lo_i,
                 //output
                 hi_o,
                 lo_o
                );
                
input clk;
input rst;
input we;
input [`RegBus] hi_i;
input [`RegBus] lo_i;
output reg [`RegBus] hi_o;
output reg [`RegBus] lo_o;

reg [`RegBus] reg_hi;
reg [`RegBus] reg_lo;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    reg_hi <= `ZeroWord;
    reg_lo <= `ZeroWord;
  end
  else if(we == `WriteEnable) begin
    reg_hi <= hi_i;
    reg_lo <= lo_i;
  end
  else ;
end

always@(*) begin
  hi_o <= reg_hi;
  lo_o <= reg_lo;
end

/*always @(posedge clk) begin
  if (rst == `RstEnable) begin
    hi_o <= `ZeroWord;
    lo_o <= `ZeroWord;
  end 
  else if((we == `WriteEnable)) begin
    hi_o <= hi_i;
    lo_o <= lo_i;
  end
  else ;
end*/

endmodule




  
    