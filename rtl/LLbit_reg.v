`include "define.v"
module LLbit_reg(
                 //input
                 clk,
                 rst,
                 we,
                 LLbit_i,
                 flush,
                 //output
                 LLbit_o
                );

input clk;
input rst;
input we;
input LLbit_i;
input flush;
output reg LLbit_o;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    LLbit_o <= 1'b0;
  end 
  else if(flush == 1'b1) begin
    LLbit_o <= 1'b0;
  end 
  else if(we == `WriteEnable) begin
    LLbit_o <= LLbit_i;
  end
  else ;
end

endmodule

  
                    
