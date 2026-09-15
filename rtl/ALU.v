// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\ALU.v
//
// Module `ALU` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module ALU(A, B, ALUOp, zero, ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

    assign zero = (ALU_result == 32'b0) ? 1'b1 : 1'b0;

    always @(*) begin
        case (ALUOp)
            `ALUOp_ADD: ALU_result = A + B;
            `ALUOp_SUB: ALU_result = A - B;
            `ALUOp_AND: ALU_result = A & B;
            `ALUOp_OR : ALU_result = A | B;
            `ALUOp_XOR: ALU_result = A ^ B;
            `ALUOp_SLL: ALU_result = A << B[4:0];

            `ALUOp_SRL: ALU_result = $unsigned(A) >> B[4:0];
            `ALUOp_SRA: ALU_result = A >>> B[4:0];
            `ALUOp_BR : ALU_result = A - B;
            default   : ALU_result = A + B;
        endcase
    end
    endmodule
