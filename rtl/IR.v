// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\IR.v
//
// Module `IR` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module IR(in_ins, clk, IRWrite, out_ins);
    input clk, IRWrite;
    input [31:0] in_ins;
    output reg[31:0] out_ins;

    always @(posedge clk) begin
        if (IRWrite) begin
            out_ins <= in_ins;
        end
    end
    endmodule
