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
							//output
							wb_wreg,
							wb_wd,
							wb_wdata,
							wb_whilo,
							wb_hi,
							wb_lo
						 );
						 
input clk;
input rst;
input mem_wreg;
input [`RegAddrBus] mem_wd;
input [`RegBus] mem_wdata;
input mem_whilo;
input [`RegBus] mem_hi;
input [`RegBus] mem_lo;

output reg wb_wreg;
output reg [`RegAddrBus] wb_wd;
output reg [`RegBus] wb_wdata;
output reg wb_whilo;
output reg [`RegBus] wb_hi;
output reg [`RegBus] wb_lo;

always@(posedge clk) begin
	if(rst == `RstEnable) begin
		wb_wreg  <= `WriteDisable;
		wb_wd    <= `NOPRegAddr;
		wb_wdata <= `ZeroWord;
		wb_whilo <= `WriteDisable;
		wb_hi <= `ZeroWord;
		wb_lo <= `ZeroWord;
	end
	else begin
		wb_wreg  <= mem_wreg;
		wb_wd    <= mem_wd;
		wb_wdata <= mem_wdata;
		wb_whilo <= mem_whilo;
		wb_hi <= mem_hi;
		wb_lo <= mem_lo;
	end
end

endmodule