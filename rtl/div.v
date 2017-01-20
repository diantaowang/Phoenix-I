`include "define.v"
module div(
           //input 
           rst,
           clk,
           start_i,
           signed_div_i,
           opdata1_i,
           opdata2_i,
           annul_i,
           //output
           result_o,
           ready
          );
 
input rst;
input clk;
input signed_div_i;
input [`RegBus] opdata1_i;
input [`RegBus] opdata2_i;
input start_i;
input annul_i;
output reg [`DoubleBus] result_o;
output reg ready; 

reg [5:0]  cnt;
reg [64:0] dividend;
reg [1:0]  state;
reg [31:0] divisor;
reg [31:0] temp_op1;
reg [31:0] temp_op2;
wire [32:0] div_temp;

assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

always@(posedge clk) begin
  if(rst == `RstEnable) begin
    result_o <= {`ZeroWord,`ZeroWord};
    ready <= `DivResultNotReady;
    cnt <= 6'b000000;
    state <= `DivFree;
  end
  else begin
    case(state)
      `DivFree: begin
        if((start_i == `DivStart) && (annul_i == 1'b0)) begin
          if(opdata2_i == `ZeroWord) begin
            state <= `DivByZero;
          end
          else begin
            state <= `DivOn;
            cnt <= 6'b000000;
            temp_op1 = ((signed_div_i == 1'b1) && (opdata1_i[31] == 1'b1)) ? (~opdata1_i + 1) : opdata1_i;
            temp_op2 = ((signed_div_i == 1'b1) && (opdata2_i[31] == 1'b1)) ? (~opdata2_i + 1) : opdata2_i;
            dividend <= {`ZeroWord,temp_op1,1'b0};
            divisor <= temp_op2;
          end
        end
        else begin
          // state <= `DivEnd;    //This sentence must not appear 
          result_o <= {`ZeroWord,`ZeroWord};
          ready <= `DivResultNotReady;
        end
      end
      `DivByZero: begin
        state <= `DivEnd;
        dividend <= {1'b0,`ZeroWord,`ZeroWord};
      end
      `DivOn: begin
        if(annul_i == 1'b0) begin
          if(cnt < 6'b100000) begin
            if(div_temp[32] == 1'b1) begin
              dividend <= {dividend[63:0],1'b0};
            end
            else begin 
              dividend <= {div_temp[31:0],dividend[31:0],1'b1};
            end
            cnt <= cnt + 1'b1;
          end
          else if (cnt == 6'b100000) begin
            cnt <= 6'b000000;
            state <= `DivEnd;
            if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
              dividend[31:0] <= (~dividend[31:0]) + 1;
            end else ;
            //The remainder is the same as the dividend symbol
            if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin
              dividend[64:33] <= (~dividend[64:33]) + 1;      
            end else ;      
          end
          else begin
            cnt <= 6'b000000;
            state <= `DivEnd;
            dividend <= {1'b0,`ZeroWord,`ZeroWord};
          end       // care
        end
        else begin
          state <= `DivFree;
        end
      end
      `DivEnd: begin
        result_o <= {dividend[64:33],dividend[31:0]};
        ready <= `DivResultReady;
        if(start_i <= `DivStop) begin
          state <= `DivFree;
          result_o <= {`ZeroWord,`ZeroWord};
          ready <= `DivResultNotReady;
        end
      end
    endcase
  end
end

endmodule



  
