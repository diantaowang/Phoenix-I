`include "define.v"
module ctrl(
            //input 
            rst,
            stallreq_from_id,
            stallreq_from_ex,
            cp0_epc_i,
            excepttype_i,
            //output
            stall,
            new_pc,
            flush
           );
           
input rst;
input stallreq_from_id;
input stallreq_from_ex;
input [`RegBus] cp0_epc_i;
input [31:0] excepttype_i;
output reg [5:0] stall;
output reg [`RegBus] new_pc;
output reg flush;

always@(*) begin
  if(rst == `RstEnable) begin
    stall <= 6'b000000;
    new_pc <= `ZeroWord;
    flush <= 1'b0;
  end
  else begin
    new_pc <= `ZeroWord;
    flush <= 1'b0;
    stall <= 6'b000000;
    if(excepttype_i != `ZeroWord) begin
      flush <= 1'b1;
      case(excepttype_i)
        32'h0000_0001: begin      //interrupt
          new_pc <= 32'h0000_0020;
        end
        32'h0000_0008: begin      //syscall
          new_pc <= 32'h0000_0040;
        end
        32'h0000_000a: begin      //undefine
          new_pc <= 32'h0000_0040;
        end
        32'h0000_000c: begin      //ov
          new_pc <= 32'h0000_0040;
        end
        32'h0000_000d: begin      //trap
          new_pc <= 32'h0000_0040;
        end
        32'h0000_000e: begin      //eret
          new_pc <= cp0_epc_i;  
        end
        default: begin  
        end
      endcase
    end
    else if(stallreq_from_id == `Stop) begin
      stall <= 6'b000111;
    end
    else if(stallreq_from_ex == `Stop) begin
      stall <= 6'b001111;
    end
    else begin
      stall <= 6'b000000;
    end
  end
end

endmodule 
