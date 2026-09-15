// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\MUX_3to1_LMD.v
//
// Module `MUX_3to1_LMD` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module MUX_3to1_LMD(X,Y,Z,control,out);
    input [31:0] X;
    input [31:0] Y;
    input [31:2] Z;  
    input [1:0] control;
    output reg[31:0] out;

    always @ (X or Y or Z or control)  begin
        case(control)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z;
            `WDSel_Else    : out = 0;
        endcase
    end
    endmodule
