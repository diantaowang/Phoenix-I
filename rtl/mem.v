`include "define.v"
module mem(
           //input
           rst,
           wreg_i,
           wd_i,         
           wdata_i,
           whilo_i,
           hi_i,
           lo_i,
           //output
           wreg_o,
           wd_o,
           wdata_o,
           whilo_o,
           hi_o,
           lo_o
          );
          
input rst;
input wreg_i;
input [`RegAddrBus] wd_i;
input [`RegBus] wdata_i;
input whilo_i;
input [`RegBus] hi_i;
input [`RegBus] lo_i;

output reg wreg_o;
output reg [`RegAddrBus] wd_o;
output reg [`RegBus] wdata_o;
output reg whilo_o;
output reg [`RegBus] hi_o;
output reg [`RegBus] lo_o;
          
always@(*) begin
  if(rst == `RstEnable) begin
    wreg_o  <= `WriteDisable;
    wd_o    <= `NOPRegAddr;
    wdata_o <= `ZeroWord;
    whilo_o <= `WriteDisable;
    hi_o    <= `ZeroWord;
    lo_o    <= `ZeroWord;
  end
  else begin
    wreg_o  <= wreg_i;
    wd_o    <= wd_i;
    wdata_o <= wdata_i;
    whilo_o <= whilo_i;
    hi_o    <= hi_i;
    lo_o    <= lo_i;
  end
end

endmodule

    
    
