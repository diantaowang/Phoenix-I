`include "../rtl/define.v"
`timescale 1ns/1ps
module openmips_min_sopc_tb;

reg clk_50M;
reg rst;

initial begin
	 clk_50M <= 1'b0;
	 forever #10 clk_50M <= ~clk_50M;
end

initial begin
	rst = `RstEnable;
	#195 rst = `RstDisable;
	#3000
		$stop;
end

openmips_min_sopc openmips_min_sopc0(
		.clk(clk_50M),
		.rst(rst)
);

`ifdef DUMP_FSDB
initial begin
	$fsdbDumpfile("test.fsdb");
	$fsdbDumpvars;
end
`endif	

endmodule

	
	
