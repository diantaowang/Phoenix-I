`include "define.v"
module openmips_min_sopc(
												 //input
												 clk,
												 rst
												);
												
input rst;
input clk;

wire [`InstAddrBus] inst_addr;
wire [`InstBus] inst;
wire rom_ce;

openmips openmips0(
		//input 
		.clk(clk),
		.rst(rst),
		.rom_data_i(inst),
		//output
		.rom_addr_o(inst_addr),				
		.rom_ce_o(rom_ce) 
);
		
inst_rom inst_rom0(
		//input 
		.ce(rom_ce),
		.addr(inst_addr),
		//output
		.inst(inst)
);

endmodule
