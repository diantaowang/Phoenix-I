`include "define.v"
module ex_mem(
              //input
              clk,
              rst,
              ex_wreg,
              ex_wd,
              ex_wdata,
              ex_whilo,
              ex_hi,
              ex_lo,
              stall,
              hilo_i,
              cnt_i,
              ex_aluop,
              ex_mem_addr,
              ex_reg2,
              ex_cp0_reg_data,
              ex_cp0_reg_write_addr,
              ex_cp0_reg_we,
              //output
              mem_wreg,
              mem_wd,
              mem_wdata,
              mem_whilo,
              mem_hi,
              mem_lo,
              hilo_o,
              cnt_o,
              mem_aluop,
              mem_mem_addr,
              mem_reg2,
              mem_cp0_reg_data,
              mem_cp0_reg_write_addr,
              mem_cp0_reg_we
             );
             
input clk;
input rst;
input ex_wreg;
input [`RegAddrBus] ex_wd;
input [`RegBus] ex_wdata;
input ex_whilo;
input [`RegBus] ex_hi;
input [`RegBus] ex_lo;
input [5:0] stall;
input [`DoubleBus] hilo_i;
input [1:0] cnt_i;
input [`AluOpBus] ex_aluop;
input [`RegBus] ex_mem_addr;
input [`RegBus] ex_reg2;
input [`RegBus] ex_cp0_reg_data;
input [4:0] ex_cp0_reg_write_addr;
input ex_cp0_reg_we;

output reg mem_wreg;
output reg [`RegAddrBus] mem_wd;
output reg [`RegBus] mem_wdata;
output reg mem_whilo;
output reg [`RegBus] mem_hi;
output reg [`RegBus] mem_lo;
output reg [`DoubleBus] hilo_o;
output reg [1:0] cnt_o;
output reg [`AluOpBus] mem_aluop;
output reg [`RegBus] mem_mem_addr;
output reg [`RegBus] mem_reg2;
output reg [`RegBus] mem_cp0_reg_data;
output reg [4:0] mem_cp0_reg_write_addr;
output reg mem_cp0_reg_we;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    mem_wreg  <= `WriteDisable;
    mem_wd    <= `NOPRegAddr;
    mem_wdata <= `ZeroWord;
    mem_whilo <= `WriteDisable;
    mem_hi <= `ZeroWord;
    mem_lo <= `ZeroWord;
    hilo_o <= {`ZeroWord,`ZeroWord};
    cnt_o  <= 2'b00;
    mem_aluop <= `EXE_NOP_OP;
    mem_mem_addr <= `ZeroWord;
    mem_reg2 <= `ZeroWord;
    mem_cp0_reg_data <= `ZeroWord;
    mem_cp0_reg_write_addr <= 5'b00000;
    mem_cp0_reg_we <= `WriteDisable;
  end
  else if(stall[3] == `Stop && stall[4] == `NoStop) begin
    mem_wreg  <= `WriteDisable;
    mem_wd    <= `NOPRegAddr;
    mem_wdata <= `ZeroWord;
    mem_whilo <= `WriteDisable;
    mem_hi <= `ZeroWord;
    mem_lo <= `ZeroWord;
    hilo_o <= hilo_i;
    cnt_o  <= cnt_i;
    mem_aluop <= `EXE_NOP_OP;
    mem_mem_addr <= `ZeroWord;
    mem_reg2 <= `ZeroWord; 
    mem_cp0_reg_data <= `ZeroWord;
    mem_cp0_reg_write_addr <= 5'b00000;
    mem_cp0_reg_we <= `WriteDisable; 
  end
  else if(stall[3] == `NoStop) begin
    mem_wreg  <= ex_wreg;
    mem_wd    <= ex_wd;
    mem_wdata <= ex_wdata;
    mem_whilo <= ex_whilo;
    mem_hi <= ex_hi;
    mem_lo <= ex_lo;
    hilo_o <= {`ZeroWord,`ZeroWord};
    cnt_o  <= 2'b00;
    mem_aluop <= ex_aluop;
    mem_mem_addr <= ex_mem_addr;
    mem_reg2 <= ex_reg2;
    mem_cp0_reg_data <= ex_cp0_reg_data;
    mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
    mem_cp0_reg_we <= ex_cp0_reg_we;
  end
  else begin
    hilo_o <= hilo_i;
    cnt_o <= cnt_i;
  end
end

endmodule
  
