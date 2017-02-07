module cp0_reg(
               //input
               rst,
               clk,
               int_i,
               we_i,
               waddr_i,
               data_i,
               raddr_i,
               //output
               data_o,
               timer_int_o,
               count_o,
               compare_o,
               status_o,
               cause_o,
               epc_o,
               config_o,
               prid_o
              );
              
input rst;
input clk;
input [5:0] int_i;
input we_i;
input [4:0] waddr_i;
input [`RegBus] data_i;
input [4:0] raddr_i;

output reg [`RegBus] data_o;
output reg timer_int_o;
output reg [`RegBus] count_o;
output reg [`RegBus] compare_o;
output reg [`RegBus] status_o;
output reg [`RegBus] cause_o;
output reg [`RegBus] epc_o;
output reg [`RegBus] config_o;
output reg [`RegBus] prid_o;   

// read: mfc0
always@(*) begin
  if(rst == `RstDisable) begin
    data_o <= `ZeroWord;
  end 
  else begin
    case(raddr_i)
      `CP0_REG_COUNT: begin
        data_o <= count_o;
      end
      `CP0_REG_COMPARE: begin
        data_o <= compare_o;
      end
      `CP0_REG_STATUS: begin
        data_o <= status_o;
      end
      `CP0_REG_CAUSE: begin
        data_o <= cause_o;
      end
      `CP0_REG_EPC: begin
        data_o <= epc_o;
      end
      `CP0_REG_CONFIG: begin
        data_o <= config_o;
      end
      `CP0_REG_PrId: begin
        data_o <= prid_o;
      end
      default: begin
        data_o <= `ZeroWord;
      end
    endcase
  end
end 

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    timer_int_o <= `InterruptNotAssert;
    count_o <= `ZeroWord;
    compare_o <= `ZeroWord;
    status_o <= 32'h1000_0000;
    cause_o <= `ZeroWord;
    epc_o <= `ZeroWord;
    config_o <= 32'h0000_8000;
    prid_o <= `ZeroWord;
  end
  else begin
    count_o <= count_o + 32'h1;
    cause_o[15:10] <= int_i;
    if((compare_o != 32'h0) && (compare_o == count_o)) begin
      timer_int_o <= `InterruptAssert;
    end
    else ;
    if(we_i == `WriteEnable) begin
      case(waddr_i)
        `CP0_REG_COUNT: begin
          count_o <= data_i;
        end
        `CP0_REG_COMPARE: begin
          compare_o <= data_i;
          timer_int_o <= `InterruptNotAssert;
        end
        `CP0_REG_STATUS: begin
          status_o <= data_i;
        end
        `CP0_REG_EPC: begin
          epc_o <= data_i;
        end
        `CP0_REG_CAUSE: begin
          cause_o[23] <= data_i[23];
          cause_o[22] <= data_i[22];
          cause_o[9:8] <= data_i[9:8];
        end
        default: begin
        end
      endcase
    end
    else ;
  end
end 

endmodule
        
