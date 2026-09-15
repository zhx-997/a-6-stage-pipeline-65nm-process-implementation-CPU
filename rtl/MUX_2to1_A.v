// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\MUX_2to1_A.v
//
// Module `MUX_2to1_A` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module MUX_2to1_A(X, Y, control, out );
input [31:0] X;
input [4:0] Y;
input control;
output [31:0] out;

assign out = ( control == 1'b0 ? X : {27'b0, Y[4:0]});
endmodule
