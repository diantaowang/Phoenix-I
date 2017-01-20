`include "define.v"
module pc_reg(
              //input 
              clk,
              rst,
              stall,
              //output
              pc,
              ce,
              branch_flag_i,
              branch_target_address_i
             );

input clk;
input rst;
input [5:0] stall;
input branch_flag_i;
input [`InstAddrBus] branch_target_address_i;
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
  else if(stall[0] == `NoStop) begin
    if(branch_flag_i == `Branch) begin
      pc <= branch_target_address_i;
    end else begin
      pc <= pc + 32'h4;
    end
  end
  else ;    // stall[0] == 1'b1 <--> keep
end

endmodule
