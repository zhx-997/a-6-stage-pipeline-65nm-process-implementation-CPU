// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\PC.v
//
// Module `PC` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module PC(clk,rst,PCWrite,NPC,PC);
    input clk;
    input rst;
    input PCWrite;
    input [31:0] NPC;
    output reg [31:0] PC;

    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            PC <= 32'h0000_2000;
        end
        else if (PCWrite) begin
            PC <= NPC;
        end
    end
    endmodule
