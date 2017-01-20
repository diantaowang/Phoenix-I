`include "define.v"
module if_id(
             //input
             rst,
             clk,
             if_pc,
             if_inst,
             stall,
             //output
             id_pc,
             id_inst
            );
            
input rst;
input clk;
input [`InstAddrBus] if_pc;
input [`InstBus] if_inst;
input [5:0] stall;
output reg [`InstAddrBus] id_pc;
output reg [`InstBus] id_inst;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    id_pc <= `ZeroWord;
    id_inst <= `ZeroWord;
  end 
  else if(stall[1] == `Stop && stall[2] == `NoStop) begin
    id_pc <= `ZeroWord;
    id_inst <= `ZeroWord;
  end 
  else if(stall[1] == `NoStop) begin
    id_pc <= if_pc;
    id_inst <= if_inst;
  end
  else ;    // stall[2:1] == 2'b11 <--> keep
end

endmodule

