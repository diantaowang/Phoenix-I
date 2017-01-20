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
              //output
              mem_wreg,
              mem_wd,
              mem_wdata,
              mem_whilo,
              mem_hi,
              mem_lo
             );
             
input clk;
input rst;
input ex_wreg;
input [`RegAddrBus] ex_wd;
input [`RegBus] ex_wdata;
input ex_whilo;
input [`RegBus] ex_hi;
input [`RegBus] ex_lo;

output reg mem_wreg;
output reg [`RegAddrBus] mem_wd;
output reg [`RegBus] mem_wdata;
output reg mem_whilo;
output reg [`RegBus] mem_hi;
output reg [`RegBus] mem_lo;

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    mem_wreg  <= `WriteDisable;
    mem_wd    <= `NOPRegAddr;
    mem_wdata <= `ZeroWord;
    mem_whilo <= `WriteDisable;
    mem_hi <= `ZeroWord;
    mem_lo <= `ZeroWord;
  end
  else begin
    mem_wreg  <= ex_wreg;
    mem_wd    <= ex_wd;
    mem_wdata <= ex_wdata;
    mem_whilo <= ex_whilo;
    mem_hi <= ex_hi;
    mem_lo <= ex_lo;
  end
end

endmodule
  