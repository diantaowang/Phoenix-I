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
           //input load && store
           aluop_i,
           mem_addr_i,
           reg2_i,
           mem_data_i,
           LLbit_i,
           wb_LLbit_we_i,
           wb_LLbit_value_i,
           //input cp0
           cp0_reg_data_i,
           cp0_reg_write_addr_i,
           cp0_reg_we_i,
           //input exception
           excepttype_i,
           current_inst_address_i,
           is_in_delayslot_i,
           cp0_status_i,
           cp0_cause_i,
           cp0_epc_i,
           wb_cp0_reg_we,
           wb_cp0_reg_write_address,
           wb_cp0_reg_data,
           //output
           wreg_o,
           wd_o,
           wdata_o,
           whilo_o,
           hi_o,
           lo_o,
           //output load && store
           mem_addr_o,
           mem_we_o,
           mem_sel_o,
           mem_data_o,
           mem_ce_o,
           LLbit_we_o,
           LLbit_value_o,
           cp0_reg_data_o,
           cp0_reg_write_addr_o,
           cp0_reg_we_o,
           //output exception
           excepttype_o,
           current_inst_address_o,
           is_in_delayslot_o,
           cp0_epc_o
          );
          
input rst;
input wreg_i;
input [`RegAddrBus] wd_i;
input [`RegBus] wdata_i;
input whilo_i;
input [`RegBus] hi_i;
input [`RegBus] lo_i;
//input load && store
input [`AluOpBus] aluop_i;
input [`RegBus] mem_addr_i;
input [`RegBus] reg2_i;
input [`RegBus] mem_data_i;
input LLbit_i;
input wb_LLbit_we_i;
input wb_LLbit_value_i;
//input cp0
input [`RegBus] cp0_reg_data_i;
input [4:0] cp0_reg_write_addr_i;
input cp0_reg_we_i;
//input exception
input [31:0] excepttype_i;
input [`RegBus] current_inst_address_i;
input is_in_delayslot_i;
input [`RegBus] cp0_status_i;
input [`RegBus] cp0_cause_i;
input [`RegBus] cp0_epc_i;
input wb_cp0_reg_we;
input [4:0] wb_cp0_reg_write_address;
input [`RegBus] wb_cp0_reg_data;

output reg wreg_o;
output reg [`RegAddrBus] wd_o;
output reg [`RegBus] wdata_o;
output reg whilo_o;
output reg [`RegBus] hi_o;
output reg [`RegBus] lo_o;
//output load && store
output reg [`RegBus] mem_addr_o;
output wire mem_we_o;
output reg [3:0] mem_sel_o;
output reg [`RegBus] mem_data_o;
output reg mem_ce_o;
output reg LLbit_we_o;
output reg LLbit_value_o;
output reg [`RegBus] cp0_reg_data_o;
output reg [4:0] cp0_reg_write_addr_o;
output reg cp0_reg_we_o;
//output exception
output reg [31:0] excepttype_o;
output wire [`RegBus] current_inst_address_o;
output wire is_in_delayslot_o;
output wire [`RegBus] cp0_epc_o;

reg mem_we;
reg LLbit;
reg [`RegBus] cp0_status;
reg [`RegBus] cp0_cause;
reg [`RegBus] cp0_epc;

assign mem_we_o = mem_we & (~(|excepttype_o));
assign cp0_epc_o = cp0_epc;
assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;

always@(*) begin
  if(rst == `RstEnable) begin
    LLbit <= 1'b0;
  end else begin
    if(wb_LLbit_we_i == `WriteEnable) begin
      LLbit <= wb_LLbit_value_i;
    end else begin
      LLbit <= LLbit_i;
    end
  end
end

always@(*) begin
  if(rst == `RstEnable) begin
    cp0_status <= `ZeroWord;
  end 
  else begin
    if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_address == `CP0_REG_STATUS) begin
      cp0_status <= wb_cp0_reg_data;
    end else begin
      cp0_status <= cp0_status_i;
    end
  end
end

always@(*) begin
  if(rst == `RstEnable) begin
    cp0_epc <= `ZeroWord;
  end 
  else begin
    if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_address == `CP0_REG_EPC) begin
      cp0_epc <= wb_cp0_reg_data;
    end else begin
      cp0_epc <= cp0_epc_i;
    end
  end
end

always@(*) begin
  if(rst == `RstEnable) begin
    cp0_cause <= `ZeroWord;
  end 
  else begin
    if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_address == `CP0_REG_CAUSE) begin
      cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
      cp0_cause[22] <= wb_cp0_reg_data[22];
      cp0_cause[23] <= wb_cp0_reg_data[23];
    end else begin
      cp0_cause <= cp0_cause_i;
    end
  end
end

always@(*) begin
  if(rst == `RstEnable) begin
    excepttype_o <= `ZeroWord;
  end 
  else begin
    excepttype_o <= `ZeroWord;
    if(current_inst_address_i != `ZeroWord) begin
      if(((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) && (cp0_status[1:0] == 2'b01)) begin
        excepttype_o <= 32'h0000_0001;    //interrupt
      end 
      else if(excepttype_i[8] == 1'b1) begin
        excepttype_o <= 32'h0000_0008;    //syscall
      end
      else if(excepttype_i[9] == 1'b1) begin
        excepttype_o <= 32'h0000_000a;    //undefine
      end
      else if(excepttype_i[10] == 1'b1) begin
        excepttype_o <= 32'h0000_000d;    //trap
      end
      else if(excepttype_i[11] == 1'b1) begin
        excepttype_o <= 32'h0000_000c;    //ov
      end
      else if(excepttype_i[12] == 1'b1) begin
        excepttype_o <= 32'h0000_000e;    //eret
      end
      else ;
    end
  end
end
          
always@(*) begin
  if(rst == `RstEnable) begin
    wreg_o  <= `WriteDisable;
    wd_o    <= `NOPRegAddr;
    wdata_o <= `ZeroWord;
    whilo_o <= `WriteDisable;
    hi_o    <= `ZeroWord;
    lo_o    <= `ZeroWord;
    mem_addr_o <= `ZeroWord;
    mem_we  <= `WriteDisable;
    mem_sel_o <= 4'b0000;
    mem_data_o <= `ZeroWord; 
    mem_ce_o <= `ChipDisable;
    LLbit_we_o <= `WriteDisable;
    LLbit_value_o <= 1'b0;
    cp0_reg_data_o <= `ZeroWord;
    cp0_reg_write_addr_o <= 5'b00000;
    cp0_reg_we_o <= `WriteDisable;
  end
  else begin
    wreg_o  <= wreg_i;
    wd_o    <= wd_i;
    wdata_o <= wdata_i;
    whilo_o <= whilo_i;
    hi_o    <= hi_i;
    lo_o    <= lo_i;
    mem_addr_o <= `ZeroWord;
    mem_we  <= `WriteDisable;
    mem_sel_o <= 4'b1111;
    mem_data_o <= `ZeroWord; 
    mem_ce_o <= `ChipDisable;
    LLbit_we_o <= `WriteDisable;
    LLbit_value_o <= 1'b0;
    cp0_reg_data_o <= cp0_reg_data_i;
    cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
    cp0_reg_we_o <= cp0_reg_we_i;
    case(aluop_i)
      `EXE_LB_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
            mem_sel_o <= 4'b1000;
          end
          2'b01: begin
            wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
            mem_sel_o <= 4'b0100;
          end
          2'b10: begin
            wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
            mem_sel_o <= 4'b0010;
          end
          2'b11: begin
            wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
            mem_sel_o <= 4'b0001;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      `EXE_LBU_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= {24'b0,mem_data_i[31:24]};
            mem_sel_o <= 4'b1000;
          end
          2'b01: begin
            wdata_o <= {24'b0,mem_data_i[23:16]};
            mem_sel_o <= 4'b0100;
          end
          2'b10: begin
            wdata_o <= {24'b0,mem_data_i[15:8]};
            mem_sel_o <= 4'b0010;
          end
          2'b11: begin
            wdata_o <= {24'b0,mem_data_i[7:0]};
            mem_sel_o <= 4'b0001;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      `EXE_LH_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
            mem_sel_o <= 4'b1100;
          end
          2'b10: begin
            wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
            mem_sel_o <= 4'b0011;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      `EXE_LHU_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= {16'b0,mem_data_i[31:16]};
            mem_sel_o <= 4'b1100;
          end
          2'b10: begin
            wdata_o <= {16'b0,mem_data_i[15:0]};
            mem_sel_o <= 4'b0011;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      /*`EXE_LW_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= mem_data_i;
            mem_sel_o <= 4'b1111;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end*/
      `EXE_LW_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        wdata_o <= mem_data_i;
        mem_sel_o <= 4'b1111;
      end
      `EXE_LWL_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        mem_sel_o <= 4'b1111;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= mem_data_i;
          end
          2'b01: begin
            wdata_o <= {mem_data_i[23:0],reg2_i[7:0]};
          end
          2'b10: begin
            wdata_o <= {mem_data_i[15:0],reg2_i[15:0]};
          end
          2'b11: begin
            wdata_o <= {mem_data_i[7:0],reg2_i[23:0]};
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      `EXE_LWR_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        mem_sel_o <= 4'b1111;
        case(mem_addr_i[1:0])
          2'b00: begin
            wdata_o <= {reg2_i[31:8],mem_data_i[31:24]};
          end
          2'b01: begin
            wdata_o <= {reg2_i[31:16],mem_data_i[31:16]};
          end
          2'b10: begin
            wdata_o <= {reg2_i[31:24],mem_data_i[31:8]};
          end
          2'b11: begin
            wdata_o <= mem_data_i;
          end
          default: begin
            wdata_o <= `ZeroWord;
          end 
        endcase
      end
      `EXE_LL_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipEnable;
        wdata_o <= mem_data_i;
        mem_sel_o <= 4'b1111;
        LLbit_we_o <= `WriteEnable;
        LLbit_value_o <= 1'b1;
      end
      `EXE_SB_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteEnable;
        mem_ce_o <= `ChipEnable;
        mem_data_o <= {4{reg2_i[7:0]}};
        case(mem_addr_i[1:0])
          2'b00: begin
            mem_sel_o <= 4'b1000;
          end
          2'b01: begin
            mem_sel_o <= 4'b0100;
          end
          2'b10: begin
            mem_sel_o <= 4'b0010;
          end
          2'b11: begin
            mem_sel_o <= 4'b0001;
          end
          default: begin
            mem_sel_o <= 4'b0000;
          end 
        endcase
      end
      `EXE_SH_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteEnable;
        mem_ce_o <= `ChipEnable;
        mem_data_o <= {2{reg2_i[15:0]}};
        case(mem_addr_i[1:0])
          2'b00: begin
            mem_sel_o <= 4'b1100;
          end
          2'b10: begin
            mem_sel_o <= 4'b0011;
          end
          default: begin
            mem_sel_o <= 4'b0000;
          end 
        endcase
      end
      `EXE_SW_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteEnable;
        mem_ce_o <= `ChipEnable;
        mem_data_o <= reg2_i;
        mem_sel_o <= 4'b1111;
      end
      `EXE_SWL_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteEnable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            mem_data_o <= reg2_i;
            mem_sel_o <= 4'b1111;
          end
          2'b01: begin
            mem_data_o <= {8'b0,reg2_i[31:8]};
            mem_sel_o <= 4'b0111;
          end
          2'b10: begin
            mem_data_o <= {16'b0,reg2_i[31:16]};
            mem_sel_o <= 4'b0011;
          end
          2'b11: begin
            mem_data_o <= {24'b0,reg2_i[31:24]};
            mem_sel_o <= 4'b0001;
          end
          default: begin
            mem_sel_o <= 4'b0000;
          end 
        endcase
      end
      `EXE_SWR_OP: begin
        mem_addr_o <= mem_addr_i;
        mem_we <= `WriteEnable;
        mem_ce_o <= `ChipEnable;
        case(mem_addr_i[1:0])
          2'b00: begin
            mem_data_o <= {reg2_i[7:0],24'b0};
            mem_sel_o <= 4'b1000;
          end
          2'b01: begin
            mem_data_o <= {reg2_i[15:0],16'b0};
            mem_sel_o <= 4'b1100;
          end
          2'b10: begin
            mem_data_o <= {reg2_i[23:0],8'b0};
            mem_sel_o <= 4'b1110;
          end
          2'b11: begin
            mem_data_o <= reg2_i;
            mem_sel_o <= 4'b1111;
          end
          default: begin
            mem_sel_o <= 4'b0000;
          end 
        endcase
      end
      `EXE_SC_OP: begin
        if(LLbit == 1'b1) begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteEnable;
          mem_ce_o <= `ChipEnable;
          mem_data_o <= reg2_i;
          mem_sel_o <= 4'b1111;
          LLbit_we_o <= `WriteEnable;
        LLbit_value_o <= 1'b0;
          wdata_o <= 32'h1;
        end
        else begin
          wdata_o <= 32'h0;
        end
        end
      default: begin
      end
    endcase
  end
end

endmodule

    
    
