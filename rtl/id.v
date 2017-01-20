`include "define.v"
module id(
					//input 
					rst,
					pc_i,
					inst_i,
					reg1_data_i,
					reg2_data_i,
					ex_wreg_i,					
					ex_wd_i,
					ex_wdata_i,	
					mem_wreg_i,
					mem_wd_i,
					mem_wdata_i,
					//output
					aluop_o,
					alusel_o,
					reg1_o,
				 	reg2_o,
					wd_o,
					wreg_o,
					reg1_read_o,
					reg1_addr_o,
					reg2_read_o,
					reg2_addr_o		
				 );
				 
input rst;
input [`InstAddrBus] pc_i;
input [`InstBus] inst_i;
input [`RegBus] reg1_data_i;
input [`RegBus] reg2_data_i;
// ex: RAM
input ex_wreg_i;					
input [`RegAddrBus] ex_wd_i;						
input [`RegBus] ex_wdata_i;
// mem: RAM
input mem_wreg_i;
input [`RegAddrBus] mem_wd_i;
input [`RegBus] mem_wdata_i;

output reg [`AluOpBus] aluop_o;
output reg [`AluSelBus] alusel_o;
output reg [`RegBus] reg1_o;
output reg [`RegBus] reg2_o;
output reg [`RegAddrBus] reg1_addr_o;
output reg reg1_read_o;
output reg [`RegAddrBus] reg2_addr_o;
output reg reg2_read_o;
output reg wreg_o;
output reg [`RegAddrBus] wd_o;

wire [5:0] op;
wire [4:0] op2;
wire [5:0] op3;
wire [4:0] op4;
reg [`RegBus] imm;
reg instvalid;									

assign op  = inst_i[31:26];  		
assign op2 = inst_i[10:6];			
assign op3 = inst_i[5:0];				
assign op4 = inst_i[20:16];			

always@(*) begin
	if(rst == `RstEnable) begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		reg1_o <= `ZeroWord;
		reg2_o <= `ZeroWord;
		wreg_o <= `WriteDisable;
		wd_o <= `NOPRegAddr;							// address
		reg1_addr_o <= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		imm <= `ZeroWord;									
		instvalid <= `InstValid;        	
	end
	else begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wreg_o <= `WriteDisable;
		wd_o <= inst_i[15:11];
		reg1_addr_o <= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		imm <= `ZeroWord;	
		instvalid <= `InstInvalid; 					
		case(op)
			`EXE_SPECIAL_INST: begin
				case(op2) 
					5'b00000: begin
						case(op3)
							`EXE_AND: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_AND_OP;  alusel_o <=`EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_OR: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_OR_OP;		alusel_o <=`EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;    	instvalid <= `InstValid;
							end
							`EXE_XOR: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_XOR_OP;  alusel_o <=`EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_NOR: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_NOR_OP;  alusel_o <=`EXE_RES_LOGIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;			instvalid <= `InstValid;
							end
							`EXE_SLLV: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SLL_OP;  alusel_o <=`EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;			instvalid <= `InstValid;
							end
							`EXE_SRLV: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SRL_OP;  alusel_o <=`EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SRAV: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SRA_OP;  alusel_o <=`EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SYNC: begin         	
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_NOP_OP;  alusel_o <=`EXE_RES_NOP;
								reg1_read_o <= 1'b0;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
								wreg_o <= (reg2_o == `ZeroWord) ? 1'b1 : 1'b0;	
							end
							`EXE_MOVN: begin
								aluop_o <= `EXE_MOVN_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
								wreg_o <= (reg2_o != `ZeroWord) ? 1'b1 : 1'b0;	
							end
							`EXE_MFHI: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_MFHI_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b0;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
							end
							`EXE_MFLO: begin
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_MFLO_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b0;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
							end
							`EXE_MTHI: begin
								wreg_o <= `WriteDisable; aluop_o <= `EXE_MTHI_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
							end
							`EXE_MTLO: begin
								wreg_o <= `WriteDisable; aluop_o <= `EXE_MTLO_OP; alusel_o <=`EXE_RES_MOVE;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
							end
							`EXE_ADD: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_ADD_OP;  alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_ADDU: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_ADDU_OP; alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SUB: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SUB_OP;  alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SUBU: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SUBU_OP; alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SLT: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SLT_OP;  alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_SLTU: begin    
								wreg_o <= `WriteEnable;  aluop_o <= `EXE_SLTU_OP; alusel_o <=`EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_MULT: begin    
								wreg_o <= `WriteDisable; aluop_o <= `EXE_MULT_OP; 
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							`EXE_MULTU: begin    
								wreg_o <= `WriteDisable; aluop_o <= `EXE_MULTU_OP;
								reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
							end
							default: begin         		
							end
						endcase	
					end
					default: begin								
					end	
				endcase					
			end
			`EXE_SPECIAL2_INST: begin
				case(op3)
					`EXE_CLZ: begin
					  wreg_o <= `WriteEnable;  aluop_o <= `EXE_CLZ_OP;  alusel_o <=`EXE_RES_ARITHMETIC;
						reg1_read_o <= 1'b1;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
					end
					`EXE_CLO: begin
					  wreg_o <= `WriteEnable;  aluop_o <= `EXE_CLO_OP;  alusel_o <=`EXE_RES_ARITHMETIC;
						reg1_read_o <= 1'b1;     reg2_read_o <= 1'b0;     instvalid <= `InstValid;
					end
					`EXE_MUL: begin
					  wreg_o <= `WriteEnable;  aluop_o <= `EXE_MUL_OP;  alusel_o <=`EXE_RES_MUL;
						reg1_read_o <= 1'b1;     reg2_read_o <= 1'b1;     instvalid <= `InstValid;
					end
					default: begin
					end
				endcase
			end
			`EXE_ANDI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_AND_OP;  			alusel_o <=`EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {16'h0,inst_i[15:0]};
			end
			`EXE_ORI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_OR_OP;  			alusel_o <=`EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {16'h0,inst_i[15:0]};
			end
			`EXE_XORI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_XOR_OP;  			alusel_o <=`EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {16'h0,inst_i[15:0]};
			end
			`EXE_LUI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_OR_OP;  			alusel_o <=`EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {inst_i[15:0],16'h0};
			end
			`EXE_PREF: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_NOP_OP;  			alusel_o <=`EXE_RES_NOP;
				reg1_read_o <= 1'b0;    		reg2_read_o <= 1'b0;     			instvalid <= `InstValid;		
			end
			`EXE_ADDI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_ADDI_OP;  		alusel_o <=`EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {{16{inst_i[15]}},inst_i[15:0]};
			end
			`EXE_ADDIU: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_ADDIU_OP;  		alusel_o <=`EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {{16{inst_i[15]}},inst_i[15:0]};
			end
			`EXE_SLTI: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_SLT_OP;  		  alusel_o <=`EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {{16{inst_i[15]}},inst_i[15:0]};
			end
			`EXE_SLTIU: begin
				wreg_o <= `WriteEnable;  		aluop_o <= `EXE_SLTU_OP;  		alusel_o <=`EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;    		reg2_read_o <= 1'b0;     			wd_o <= inst_i[20:16];
				instvalid <= `InstValid;		imm <= {{16{inst_i[15]}},inst_i[15:0]};
			end
			default: begin	
			end	
		endcase									//case op
		if(inst_i[31:21] == 11'b000_0000_0000) begin
			case(op3)
				`EXE_SLL: begin
				  wreg_o <= `WriteEnable;  		aluop_o <= `EXE_SLL_OP;  		alusel_o <=`EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;    		reg2_read_o <= 1'b1;     		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;		imm[4:0] <= inst_i[10:6];
				end
				`EXE_SRL: begin
				  wreg_o <= `WriteEnable;  		aluop_o <= `EXE_SRL_OP;  		alusel_o <=`EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;    		reg2_read_o <= 1'b1;     		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;		imm[4:0] <= inst_i[10:6];
				end
				`EXE_SRA: begin
				  wreg_o <= `WriteEnable;  		aluop_o <= `EXE_SRA_OP;  		alusel_o <=`EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;    		reg2_read_o <= 1'b1;     		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;		imm[4:0] <= inst_i[10:6];
				end
				default: begin
				end
			endcase
		end
	  else begin
	  end          			//if-else
	end									//if-else
end

// RAW 

always@(*) begin
	if(rst == `RstEnable) begin
		reg1_o <= `ZeroWord;
	end
	else begin
		if((ex_wreg_i == 1'b1) && (reg1_read_o == 1'b1) && (reg1_addr_o == ex_wd_i)) begin
			reg1_o <= ex_wdata_i;
		end
		else if((mem_wreg_i == 1'b1) && (reg1_read_o == 1'b1) && (reg1_addr_o == mem_wd_i)) begin
			reg1_o <= mem_wdata_i;
		end
		else if(reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
		end
		else if(reg1_read_o == 1'b0) begin
			reg1_o <= imm;
		end
	  else begin
			reg1_o <= `ZeroWord;
		end
	end
end

always@(*) begin
	if(rst == `RstEnable) begin
		reg2_o <= `ZeroWord;
	end
	else begin
		if((ex_wreg_i == 1'b1) && (reg2_read_o == 1'b1) && (reg2_addr_o == ex_wd_i)) begin
			reg2_o <= ex_wdata_i;
		end
		else if((mem_wreg_i == 1'b1) && (reg2_read_o == 1'b1) && (reg2_addr_o == mem_wd_i)) begin
			reg2_o <= mem_wdata_i;
		end
		else if(reg2_read_o == 1'b1) begin
			reg2_o <= reg2_data_i;
		end
		else if(reg2_read_o == 1'b0) begin
			reg2_o <= imm;
		end
	  else begin
			reg2_o <= `ZeroWord;
		end
	end
end

endmodule

