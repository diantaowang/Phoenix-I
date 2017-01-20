`include "define.v"
module pc_reg(
              //input 
              clk,
              rst,
              //output
              pc,
              ce
             );

input clk;
input rst;
output reg [`InstAddrBus] pc;
output reg ce;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    ce <= `ReadDisable;
  end
  else begin
    ce <= `ReadEnable;
  end
end

always@(posedge clk) begin
  if(ce == `ReadDisable) begin
    pc <= `ZeroWord;
  end
  else begin
    pc <= pc + 32'h4;
  end
end

endmodule
