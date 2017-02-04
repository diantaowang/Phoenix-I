`include "define.v"
module openmips_min_sopc(
                         //input
                         clk,
                         rst
                        );
                        
input rst;
input clk;

// rom
wire [`InstAddrBus] inst_addr;
wire [`InstBus] inst;
wire rom_ce;
// ram
wire [`RegBus] mem_addr_i;
wire [`RegBus] mem_data_i;
wire [3:0] mem_sel_i; 
wire mem_we_i; 
wire mem_ce_i;
wire [`RegBus] mem_data_o;

openmips openmips0(
    //input 
    .clk(clk),
    .rst(rst),
    .rom_data_i(inst),
    .ram_data_i(mem_data_o),
    //output
    .rom_addr_o(inst_addr),       
    .rom_ce_o(rom_ce),
    .ram_addr_o(mem_addr_i),
    .ram_we_o(mem_we_i),
    .ram_sel_o(mem_sel_i),
    .ram_data_o(mem_data_i),
    .ram_ce_o(mem_ce_i) 
);
    
inst_rom inst_rom0(
    //input 
    .ce(rom_ce),
    .addr(inst_addr),
    //output
    .inst(inst)
);

data_ram data_ram0(
    //input
    .ce(mem_ce_i),
    .clk(clk),
    .data_i(mem_data_i),
    .addr(mem_addr_i),
    .we(mem_we_i),
    .sel(mem_sel_i),
    //output
    .data_o(mem_data_o)
);

endmodule
