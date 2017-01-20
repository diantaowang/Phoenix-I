`include "define.v"
module regfile(
               //input
               clk,
               rst,
               re1,
               raddr1,
               re2,
               raddr2,
               we,
               waddr,
               wdata,
               //output
               rdata1,
               rdata2
              );
              
input clk;
inout rst;
input re1;
inout [`RegAddrBus] raddr1;
input re2;
input [`RegAddrBus] raddr2;
input we;
input [`RegAddrBus] waddr;
input [`RegBus] wdata;

output reg [`RegBus] rdata1;
output reg [`RegBus] rdata2;

reg [31:0] regs[31:0];

always@(posedge clk) begin
  if(rst == `RstDisable) begin
    if((we == 1'b1) && (waddr != 5'b0_0000)) begin
      regs[waddr] <= wdata;
    end else ;
  end else ;
end
            
always@(*) begin
  if(rst == `RstEnable)
    rdata1 <= `ZeroWord;
  else if(raddr1 == `NOPRegAddr)
    rdata1 <= `ZeroWord;
  else if((re1 == 1'b1) && (we == 1'b1) && (raddr1 == waddr))
    rdata1 <= wdata;
  else if(re1 == 1'b1)
    rdata1 <= regs[raddr1];
  else
    rdata1 <= `ZeroWord;
end

always@(*) begin
  if(rst == `RstEnable)
    rdata2 <= `ZeroWord;
  else if(raddr2 == `NOPRegAddr)
    rdata2 <= `ZeroWord;
  else if((re2 == 1'b1) && (we == 1'b1) && (raddr2 == waddr))
    rdata2 <= wdata;
  else if(re2 == 1'b1)
    rdata2 <= regs[raddr2];
  else
    rdata2 <= `ZeroWord;
end

endmodule

  
  
    

