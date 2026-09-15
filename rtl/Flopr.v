// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\Flopr.v
//
// Module `Flopr` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

module Flopr(clk,rst,in_data,out_data);
    input clk;
    input rst;
    input [31:0] in_data;
    output reg [31:0] out_data;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out_data <= 0;
        end
        else begin
            out_data <= in_data;
        end
    end
    endmodule
