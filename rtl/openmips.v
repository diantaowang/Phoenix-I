`include "define.v"
module openmips(
                //input 
                clk,
                rst,
                rom_data_i,
                //input ram
                ram_data_i,
                //input cp0
                int_i,
                //output
                rom_addr_o,       
                rom_ce_o,
                //output ram
                ram_addr_o,
                ram_we_o,
                ram_sel_o,
                ram_data_o,
                ram_ce_o,
                //output cp0
                timer_int_o          
               );
               
input clk;
input rst;
input [`InstBus] rom_data_i;
input [`InstBus] ram_data_i;
input [5:0] int_i;
output rom_ce_o;
output [`InstAddrBus] rom_addr_o;
output [`InstBus] ram_addr_o;
output ram_we_o;
output [3:0] ram_sel_o;
output [`InstBus] ram_data_o;
output ram_ce_o;
output timer_int_o;

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
wire [31:0] id_excepttype_o;
wire [`RegBus] id_current_inst_addr_o;

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
wire [31:0] ex_excepttype_i;
wire [`RegBus] ex_current_inst_addr_i;

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
wire [`RegBus] ex_cp0_reg_data_o;
wire [4:0] ex_cp0_reg_write_addr_o;
wire ex_cp0_reg_we_o;
wire [31:0] ex_excepttype_o;
wire [`RegBus] ex_current_inst_addr_o;
wire ex_is_in_delayslot_o;
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
// ex && cp0_reg
wire [`RegBus] cp0_reg_data;
wire [4:0] cp0_reg_read_addr;

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
wire [`RegBus] mem_cp0_reg_data_i;
wire [4:0] mem_cp0_reg_write_addr_i;
wire mem_cp0_reg_we_i;
wire [31:0] mem_excepttype_i;
wire [`RegBus] mem_current_inst_addr_i;
wire mem_is_in_delayslot_i;

// mem && mem_wb (ex)
wire mem_wreg_o;
wire [`RegAddrBus] mem_wd_o;
wire [`RegBus] mem_wdata_o;
wire mem_whilo_o;             
wire [`RegBus] mem_hi_o;
wire [`RegBus] mem_lo_o;
wire mem_LLbit_we_o;
wire mem_LLbit_value_o;
wire [`RegBus] mem_cp0_reg_data_o;
wire [4:0] mem_cp0_reg_write_addr_o;
wire mem_cp0_reg_we_o;
// mem && cp0_reg
wire [31:0] mem_excepttype_o;
wire [`RegBus] mem_current_inst_addr_o;
wire mem_is_in_delayslot_o;
// mem && ctrl
wire [`RegBus] mem_cp0_epc_o;

// mem_wb && regfile
wire wb_wreg_i;
wire [`RegAddrBus] wb_wd_i;
wire [`RegBus] wb_wdata_i;
// mem_wb && hilo_feg (ex)
wire wb_whilo_i;
wire [`RegBus] wb_hi_i;
wire [`RegBus] wb_lo_i;
// mem_wb && LLbit_reg (mem)
wire wb_LLbit_we_i;
wire wb_LLbit_value_i;
// mem_wb && cp0_reg
wire [`RegBus] wb_cp0_reg_data_i;
wire [4:0] wb_cp0_reg_write_addr_i;
wire wb_cp0_reg_we_i;

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

// LLbir_reg && mem
wire LLbit;

// ctrl && other
wire [`RegBus] new_pc;
wire flush;

// cp0_reg && mem
wire [31:0] cp0_status_o;
wire [31:0] cp0_cause_o;
wire [31:0] cp0_epc_o;
  
// pc_reg 
pc_reg pc_reg0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .flush(flush),
    .new_pc(new_pc),
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
    .flush(flush),
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
    .ex_aluop_i(ex_aluop_o),
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
    .excepttype_o(id_excepttype_o),
    .current_inst_addr_o(id_current_inst_addr_o),
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
    .flush(flush),
    .id_excepttype(id_excepttype_o),
    .id_current_inst_addr(id_current_inst_addr_o),
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
    .ex_inst(ex_inst_i),
    .ex_excepttype(ex_excepttype_i),
    .ex_current_inst_addr(ex_current_inst_addr_i)
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
    //input cp0
    .cp0_reg_data_i(cp0_reg_data),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
    //input exception
    .excepttype_i(ex_excepttype_i),
    .current_inst_addr_i(ex_current_inst_addr_i),
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
    .reg2_o(ex_reg2_o),
    //output cp0
    .cp0_reg_read_addr_o(cp0_reg_read_addr),
    .cp0_reg_data_o(ex_cp0_reg_data_o),
    .cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
    .cp0_reg_we_o(ex_cp0_reg_we_o),
    //output exception
    .excepttype_o(ex_excepttype_o),
    .current_inst_addr_o(ex_current_inst_addr_o),
    .is_in_delayslot_o(ex_is_in_delayslot_o)
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
    .ex_cp0_reg_data(ex_cp0_reg_data_o),
    .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
    .ex_cp0_reg_we(ex_cp0_reg_we_o),
    .flush(flush),
    .ex_excepttype(ex_excepttype_o),
    .ex_current_inst_addr(ex_current_inst_addr_o),
    .ex_is_in_delayslot(ex_is_in_delayslot_o),
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
    .mem_reg2(mem_reg2_i),
    .mem_cp0_reg_data(mem_cp0_reg_data_i),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
    .mem_cp0_reg_we(mem_cp0_reg_we_i),
    .mem_excepttype(mem_excepttype_i),
    .mem_current_inst_addr(mem_current_inst_addr_i),
    .mem_is_in_delayslot(mem_is_in_delayslot_i)
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
    .LLbit_i(LLbit),
    .wb_LLbit_we_i(wb_LLbit_we_i),
    .wb_LLbit_value_i(wb_LLbit_value_i),
    //input cp0
    .cp0_reg_data_i(mem_cp0_reg_data_i),
    .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
    .cp0_reg_we_i(mem_cp0_reg_we_i),
    //input exception
    .excepttype_i(mem_excepttype_i),
    .current_inst_address_i(mem_current_inst_addr_i),
    .is_in_delayslot_i(mem_is_in_delayslot_i),
    .cp0_status_i(cp0_status_o),
    .cp0_cause_i(cp0_cause_o),
    .cp0_epc_i(cp0_epc_o),
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .wb_cp0_reg_write_address(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),
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
    .mem_ce_o(ram_ce_o),
    .LLbit_we_o(mem_LLbit_we_o),
    .LLbit_value_o(mem_LLbit_value_o),
    //output cp0
    .cp0_reg_data_o(mem_cp0_reg_data_o),
    .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
    .cp0_reg_we_o(mem_cp0_reg_we_o),
    //output exception
    .excepttype_o(mem_excepttype_o),
    .current_inst_address_o(mem_current_inst_addr_o),
    .is_in_delayslot_o(mem_is_in_delayslot_o),
    .cp0_epc_o(mem_cp0_epc_o)
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
    .mem_LLbit_we(mem_LLbit_we_o),
    .mem_LLbit_value(mem_LLbit_value_o),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
    .flush(flush),
    //output
    .wb_wreg(wb_wreg_i),
    .wb_wd(wb_wd_i),
    .wb_wdata(wb_wdata_i),
    .wb_whilo(wb_whilo_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_LLbit_we(wb_LLbit_we_i),
    .wb_LLbit_value(wb_LLbit_value_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_we(wb_cp0_reg_we_i)
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
    .cp0_epc_i(mem_cp0_epc_o),
    .excepttype_i(mem_excepttype_o),
    //output
    .stall(stall),
    .new_pc(new_pc),
    .flush(flush)
);

div div0(
    //input 
    .rst(rst),
    .clk(clk),
    .start_i(div_start),
    .signed_div_i(signed_div),
    .opdata1_i(div_opdata1),
    .opdata2_i(div_opdata2),
    .annul_i(flush),
    //output
    .result_o(div_result),
    .ready(div_ready)
);

LLbit_reg LLbit_reg0(
  //input
  .clk(clk),
  .rst(rst),
  .we(wb_LLbit_we_i),
  .LLbit_i(wb_LLbit_value_i),
  .flush(flush),
  //output
  .LLbit_o(LLbit)
);

cp0_reg cp0_reg0(
  //input
  .rst(rst),
  .clk(clk),
  .int_i(int_i),
  .we_i(wb_cp0_reg_we_i),
  .waddr_i(wb_cp0_reg_write_addr_i),
  .data_i(wb_cp0_reg_data_i),
  .raddr_i(cp0_reg_read_addr),
  .excepttype_i(mem_excepttype_o),
  .current_inst_addr_i(mem_current_inst_addr_o),
  .is_in_delayslot_i(mem_is_in_delayslot_o),
  //output
  .data_o(cp0_reg_data),
  .timer_int_o(timer_int_o),
  .count_o(),
  .compare_o(),
  .status_o(cp0_status_o),
  .cause_o(cp0_cause_o),
  .epc_o(cp0_epc_o),
  .config_o(),
  .prid_o()
);

endmodule

             

