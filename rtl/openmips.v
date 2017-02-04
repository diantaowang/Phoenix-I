`include "define.v"
module openmips(
                //input 
                clk,
                rst,
                rom_data_i,
                //input ram
                ram_data_i,
                //output
                rom_addr_o,       
                rom_ce_o,
                //output ram
                ram_addr_o,
                ram_we_o,
                ram_sel_o,
                ram_data_o,
                ram_ce_o          
               );
               
input clk;
input rst;
input [`InstBus] rom_data_i;
input [`InstBus] ram_data_i;
output rom_ce_o;
output [`InstAddrBus] rom_addr_o;
output [`InstBus] ram_addr_o;
output ram_we_o;
output [3:0] ram_sel_o;
output [`InstBus] ram_data_o;
output ram_ce_o;

// openmips && extern
wire [`InstAddrBus] pc;

// if_id && id 
wire [`InstAddrBus] id_pc_i;
wire [`InstBus] id_inst_i;

// id && id_ex 
wire [`AluOpBus] id_aluop_o;
wire [`AluSelBus] id_alusel_o;
wire [`RegBus] id_reg1_o;
wire [`RegBus] id_reg2_o;
wire id_wreg_o;
wire [`RegAddrBus] id_wd_o;
wire id_is_in_delayslot_o;
wire [`RegBus] id_link_address_o;
wire next_inst_in_delayslot;
wire is_in_delayslot;
wire [`RegBus] id_inst_o;

// id_ex && ex 
wire [`AluOpBus] ex_aluop_i;
wire [`AluSelBus] ex_alusel_i;
wire [`RegBus] ex_reg1_i;
wire [`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire [`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;
wire [`RegBus] ex_link_address_i;
wire [`RegBus] ex_inst_i;

// ex && ex_mem 
wire ex_wreg_o;
wire [`RegAddrBus] ex_wd_o;
wire [`RegBus] ex_wdata_o;
wire ex_whilo_o;
wire [`RegBus] ex_hi_o;
wire [`RegBus] ex_lo_o;
wire [`AluOpBus] ex_aluop_o;
wire [`RegBus] ex_mem_addr_o;
wire [`RegBus] ex_reg2_o;
// ex -> ex_mem
wire [`DoubleBus] hilo_temp_o;
wire [1:0] cnt_o;
// ex_mem -> ex
wire [`DoubleBus] hilo_temp_i;
wire [1:0] cnt_i;
// ex && div
wire signed_div;
wire div_start;
wire [`RegBus] div_opdata1;
wire [`RegBus] div_opdata2;
wire div_ready;
wire [`DoubleBus] div_result;

// ex_mem && mem 
wire mem_wreg_i;
wire [`RegAddrBus] mem_wd_i;
wire [`RegBus] mem_wdata_i;
wire mem_whilo_i;
wire [`RegBus] mem_hi_i;
wire [`RegBus] mem_lo_i;
wire [`AluOpBus] mem_aluop_i;
wire [`RegBus] mem_mem_addr_i;
wire [`RegBus] mem_reg2_i;

// mem && mem_wb (ex)
wire mem_wreg_o;
wire [`RegAddrBus] mem_wd_o;
wire [`RegBus] mem_wdata_o;
wire mem_whilo_o;             
wire [`RegBus] mem_hi_o;
wire [`RegBus] mem_lo_o;

// mem_wb && regfile
wire wb_wreg_i;
wire [`RegAddrBus] wb_wd_i;
wire [`RegBus] wb_wdata_i;
// mem_wb && hilo_feg (ex)
wire wb_whilo_i;
wire [`RegBus] wb_hi_i;
wire [`RegBus] wb_lo_i;

// id && regfile
wire reg1_read;
wire reg2_read;
wire [`RegBus] reg1_data;
wire [`RegBus] reg2_data;
wire [`RegAddrBus] reg1_addr;
wire [`RegAddrBus] reg2_addr;

// hilo_reg && ex
wire[`RegBus] hi;
wire[`RegBus] lo;

// ctrl && other
wire [5:0] stall;
wire stallreq_from_id;  
wire stallreq_from_ex;

// pc_reg && id
wire id_branch_flag_o;
wire [`RegBus] branch_target_address;
  
// pc_reg 
pc_reg pc_reg0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    //output
    .pc(pc),
    .ce(rom_ce_o),
    .branch_flag_i(id_branch_flag_o),
    .branch_target_address_i(branch_target_address)
);

assign rom_addr_o = pc;

// if_id 
if_id if_id0(
    //input
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .stall(stall),
    //output
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// regfile 
regfile regfile0(
    //input
    .clk(clk),
    .rst(rst),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    //output
    .rdata1(reg1_data),
    .rdata2(reg2_data)
);

// id 
id id0(
    //input 
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    //input <- regfile
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
    //input <- ex
    .ex_wreg_i(ex_wreg_o),            
    .ex_wd_i(ex_wd_o),              
    .ex_wdata_i(ex_wdata_o),          
    //input <- mem
    .mem_wreg_i(mem_wreg_o),
    .mem_wd_i(mem_wd_o),
    .mem_wdata_i(mem_wdata_o),
    //input <- id_ex
    .is_in_delayslot_i(is_in_delayslot),
    //output -> id_ex
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wreg_o(id_wreg_o),
    .wd_o(id_wd_o),
    .is_in_delayslot_o(id_is_in_delayslot_o),
    .link_addr_o(id_link_address_o),
    .next_inst_in_delayslot_o(next_inst_in_delayslot),
    //output -> regfile
    .reg1_read_o(reg1_read),
    .reg1_addr_o(reg1_addr),
    .reg2_read_o(reg2_read),
    .reg2_addr_o(reg2_addr),
    .stallreq(stallreq_from_id),
    //output -> pc_reg
    .branch_target_address_o(branch_target_address),
    .branch_flag_o(id_branch_flag_o),
    .inst_o(id_inst_o)
);

// id_ex 
id_ex id_ex0( 
    //input
    .clk(clk),
    .rst(rst),
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wreg(id_wreg_o),
    .id_wd(id_wd_o),
    .stall(stall),
    .id_is_in_delayslot(id_is_in_delayslot_o),
    .id_link_address(id_link_address_o),
    .next_inst_in_delayslot_i(next_inst_in_delayslot),
    .id_inst(id_inst_o),
    //output
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wreg(ex_wreg_i),
    .ex_wd(ex_wd_i),
    .ex_is_in_delayslot(ex_is_in_delayslot_i),
    .ex_link_address(ex_link_address_i),
    .is_in_delayslot_o(is_in_delayslot),
    .ex_inst(ex_inst_i)
);

// ex
ex ex0(
    //input
    .rst(rst),
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wreg_i(ex_wreg_i),
    .wd_i(ex_wd_i),
    //input: HI LO
    .hi_i(hi),
    .lo_i(lo),
    //input RAW
    .mem_whilo_i(mem_whilo_o),
    .mem_hi_i(mem_hi_o),
    .mem_lo_i(mem_lo_o),
    .wb_whilo_i(wb_whilo_i),
    .wb_hi_i(wb_hi_i),
    .wb_lo_i(wb_lo_i),
    //input
    .cnt_i(cnt_i),
    .hilo_temp_i(hilo_temp_i),
    //input div
    .div_ready_i(div_ready),
    .div_result_i(div_result),
    //input jump && branch
    .is_in_delayslot_i(ex_is_in_delayslot_i),
    .link_address_i(ex_link_address_i),
    //input output load && store
    .inst_i(ex_inst_i),
    //output
    .wreg_o(ex_wreg_o),
    .wd_o(ex_wd_o),
    .wdata_o(ex_wdata_o),
    .whilo_o(ex_whilo_o),
    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .cnt_o(cnt_o),
    .hilo_temp_o(hilo_temp_o),
    .stallreq(stallreq_from_ex),
    //output div
    .div_start_o(div_start),
    .signed_div_o(signed_div),
    .div_opdata1_o(div_opdata1),
    .div_opdata2_o(div_opdata2),
    //output output load && store
    .aluop_o(ex_aluop_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o)
);

// ex_mem
ex_mem ex_mem0(
    //input
    .clk(clk),
    .rst(rst),
    .ex_wreg(ex_wreg_o),
    .ex_wd(ex_wd_o),
    .ex_wdata(ex_wdata_o),
    .ex_whilo(ex_whilo_o),
    .ex_hi(ex_hi_o),
    .ex_lo(ex_lo_o),
    .stall(stall),
    .hilo_i(hilo_temp_o),
    .cnt_i(cnt_o),
    .ex_aluop(ex_aluop_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2(ex_reg2_o),
    //output
    .mem_wreg(mem_wreg_i),
    .mem_wd(mem_wd_i),
    .mem_wdata(mem_wdata_i),
    .mem_whilo(mem_whilo_i),
    .mem_hi(mem_hi_i),
    .mem_lo(mem_lo_i),
    .hilo_o(hilo_temp_i),
    .cnt_o(cnt_i),
    .mem_aluop(mem_aluop_i),
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2(mem_reg2_i)
);

// mem
mem mem0(
    //input
    .rst(rst),
    .wreg_i(mem_wreg_i),
    .wd_i(mem_wd_i),
    .wdata_i(mem_wdata_i),
    .whilo_i(mem_whilo_i),
    .hi_i(mem_hi_i),
    .lo_i(mem_lo_i),
    //input load && store
    .aluop_i(mem_aluop_i),
    .mem_addr_i(mem_mem_addr_i),
    .reg2_i(mem_reg2_i),
    .mem_data_i(ram_data_i),
    //output
    .wreg_o(mem_wreg_o),
    .wd_o(mem_wd_o),
    .wdata_o(mem_wdata_o),
    .whilo_o(mem_whilo_o),
    .hi_o(mem_hi_o),
    .lo_o(mem_lo_o),
    //output load && store
    .mem_addr_o(ram_addr_o),
    .mem_we_o(ram_we_o),
    .mem_sel_o(ram_sel_o),
    .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o) 
);

// mem_wb
mem_wb mem_wb0(
    //input
    .clk(clk),
    .rst(rst),
    .mem_wreg(mem_wreg_o),
    .mem_wd(mem_wd_o),
    .mem_wdata(mem_wdata_o),
    .mem_whilo(mem_whilo_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .stall(stall),
    //output
    .wb_wreg(wb_wreg_i),
    .wb_wd(wb_wd_i),
    .wb_wdata(wb_wdata_i),
    .wb_whilo(wb_whilo_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i)
);

hilo_reg hilo_reg0(
    //input
    .clk(clk),
    .rst(rst),
    .we(wb_whilo_i),
    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),
    //output
    .hi_o(hi),
    .lo_o(lo)
);

ctrl ctrl0(
    //input 
    .rst(rst),
    .stallreq_from_id(stallreq_from_id),
    .stallreq_from_ex(stallreq_from_ex),
    //output
    .stall(stall)
);

div div0(
    //input 
    .rst(rst),
    .clk(clk),
    .start_i(div_start),
    .signed_div_i(signed_div),
    .opdata1_i(div_opdata1),
    .opdata2_i(div_opdata2),
    .annul_i(1'b0),
    //output
    .result_o(div_result),
    .ready(div_ready)
);

endmodule

             

