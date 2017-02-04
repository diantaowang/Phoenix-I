`include "define.v"
module mem_wb(
              //input
              clk,
              rst,
              mem_wreg,
              mem_wd,
              mem_wdata,
              mem_whilo,
              mem_hi,
              mem_lo,
              stall,
              mem_LLbit_we,
              mem_LLbit_value,
              //output
              wb_wreg,
              wb_wd,
              wb_wdata,
              wb_whilo,
              wb_hi,
              wb_lo,
              wb_LLbit_we,
              wb_LLbit_value
             );
             
input clk;
input rst;
input mem_wreg;
input [`RegAddrBus] mem_wd;
input [`RegBus] mem_wdata;
input mem_whilo;
input [`RegBus] mem_hi;
input [`RegBus] mem_lo;
input [5:0] stall;
input mem_LLbit_we;
input mem_LLbit_value;

output reg wb_wreg;
output reg [`RegAddrBus] wb_wd;
output reg [`RegBus] wb_wdata;
output reg wb_whilo;
output reg [`RegBus] wb_hi;
output reg [`RegBus] wb_lo;
output reg wb_LLbit_we;
output reg wb_LLbit_value;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    wb_wreg  <= `WriteDisable;
    wb_wd    <= `NOPRegAddr;
    wb_wdata <= `ZeroWord;
    wb_whilo <= `WriteDisable;
    wb_hi <= `ZeroWord;
    wb_lo <= `ZeroWord;
    wb_LLbit_we <= `WriteDisable;
    wb_LLbit_value <= 1'b0;
  end
  else if(stall[4] == `Stop && stall[5] == `NoStop) begin
    wb_wreg  <= `WriteDisable;
    wb_wd    <= `NOPRegAddr;
    wb_wdata <= `ZeroWord;
    wb_whilo <= `WriteDisable;
    wb_hi <= `ZeroWord;
    wb_lo <= `ZeroWord;
    wb_LLbit_we <= `WriteDisable;
    wb_LLbit_value <= 1'b0;
  end
  else if(stall[4] == `NoStop) begin
    wb_wreg  <= mem_wreg;
    wb_wd    <= mem_wd;
    wb_wdata <= mem_wdata;
    wb_whilo <= mem_whilo;
    wb_hi <= mem_hi;
    wb_lo <= mem_lo;
    wb_LLbit_we <= mem_LLbit_we;
    wb_LLbit_value <= mem_LLbit_value;
  end
  else ;    // keep
end

endmodule
