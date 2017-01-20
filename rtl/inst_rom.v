`include "define.v"
module inst_rom(
								//input 
								ce,
								addr,
								//output
								inst
							 );
							 
input ce;
input [`InstAddrBus] addr;
output reg [`InstBus] inst;

reg [`InstBus] init_mem[`InstMemNum-1:0];
	
initial begin
	$readmemh("/home/edauser/OpenMIPS/rtl/inst_rom.data", init_mem);
end

always@(*) begin
	if(ce == `WriteDisable) begin
		inst <= `ZeroWord;
	end
  else begin
  	inst <= init_mem[addr[`InstMemNumLog2+1:2]];
  end
end

endmodule

		

