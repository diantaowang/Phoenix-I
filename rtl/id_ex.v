`include "define.v"
module id_ex( 
             //input
             clk,
             rst,
             id_aluop,
             id_alusel,
             id_reg1,
             id_reg2,
             id_wreg,
             id_wd,
             //output
             ex_aluop,
             ex_alusel,
             ex_reg1,
             ex_reg2,
             ex_wreg,
             ex_wd
            );
            
input clk;
input rst;
input [`AluOpBus] id_aluop;
input [`AluSelBus] id_alusel;
input [`RegBus] id_reg1;
input [`RegBus] id_reg2;
input id_wreg;
input [`RegAddrBus] id_wd;

output reg [`AluOpBus] ex_aluop;
output reg [`AluSelBus] ex_alusel;
output reg [`RegBus] ex_reg1;
output reg [`RegBus] ex_reg2;
output reg ex_wreg;
output reg [`RegAddrBus] ex_wd;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    ex_aluop  <= `EXE_NOP_OP;
    ex_alusel <= `EXE_RES_NOP;
    ex_reg1   <= `ZeroWord;
    ex_reg2   <= `ZeroWord;
    ex_wreg   <= `WriteDisable;
    ex_wd     <= `NOPRegAddr;
  end
  else begin
    ex_aluop  <= id_aluop;
    ex_alusel <= id_alusel;
    ex_reg1   <= id_reg1;
    ex_reg2   <= id_reg2;
    ex_wreg   <= id_wreg; 
    ex_wd     <= id_wd;
  end 
end 

endmodule
