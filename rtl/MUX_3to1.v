// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\MUX_3to1.v
//
// Module `MUX_3to1` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module MUX_3to1(X,Y,Z,control,out);
    input [4:0] X;   //rd
    input [4:0] Y;
    input [4:0] Z;
    input [1:0] control;
    output reg[4:0] out;

    always @ (X or Y or Z or control)  begin
        case(control)
            `RegSel_rd   : out = X;
            `RegSel_rt   : out = Y;
            `RegSel_31   : out = Z;
            `RegSel_else : out = 0;
        endcase
    end
    endmodule
