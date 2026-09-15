// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\IM.v
//
// Module `IM` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module IM(clk, InsMemRW, addr, Ins);
    input clk;
    input InsMemRW;              
    input [11:2] addr;           
    output reg [31:0] Ins;      
    reg [31:0] memory[0:1023];

    always @(negedge clk) begin
        if (InsMemRW) begin
            Ins <= memory[addr]; 
        end
    end
    endmodule
