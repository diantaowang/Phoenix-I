module data_ram(
                //input
                ce,
                clk,
                data_i,
                addr,
                we,
                sel,
                //output
                data_o
               );
               
input ce;
input clk;
input [`RegBus] data_i;
input [`RegBus] addr;
input we;
input [3:0] sel;
output reg [`RegBus] data_o;

reg [`ByteWidth] data_mem0[`DataMemNum:0];  //low byte,high address
reg [`ByteWidth] data_mem1[`DataMemNum:0];  //
reg [`ByteWidth] data_mem2[`DataMemNum:0];  //
reg [`ByteWidth] data_mem3[`DataMemNum:0];  //high byte,low address

always@(posedge clk) begin
  if(ce == `ChipDisable) begin
    data_o <= 32'b0;
  end
  else if(we == `ChipEnable) begin
    if(sel[3] == 1'b1) begin
      data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
    end
    else ;
    if(sel[2] == 1'b1) begin
      data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
    end
    else ;
    if(sel[1] == 1'b1) begin
      data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
    end
    else ;
    if(sel[0] == 1'b1) begin
      data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
    end
    else ;
  end
  else ;
end

always@(*) begin
  if(ce == `ChipDisable) begin
    data_o <= 32'b0;
  end
  else if(we == `ChipDisable) begin
    data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
               data_mem2[addr[`DataMemNumLog2+1:2]],
               data_mem1[addr[`DataMemNumLog2+1:2]],
               data_mem0[addr[`DataMemNumLog2+1:2]]};
  end
  else 
    data_o <= 32'b0;
end
    
endmodule 
