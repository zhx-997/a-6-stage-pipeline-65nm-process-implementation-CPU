// riscv.v
//
// Top-level module of the 6-stage pipelined RISC-V RV32I CPU.
// Instantiates all pipeline datapath and control modules.
//
`include "riscv_defines.v"

module riscv(clk, rst);
    input clk, rst;
    
    wire [31:0] PC;
    wire [31:0] ALU_result;
    wire [31:0] WD;
    wire [31:0] DR_out;

    wire PCWrite, InsMemRW, IRWrite;
    wire RFWrite, DMCtrl, ExtSel, ALUSrcA, zero;
    wire [1:0] ALUSrcB, ALUSrcB_EX, RegSel, RegSel_EX, NPCOp, NPCOp_EX, WDSel, WDSel_WB;
    wire [3:0] ALUOp, ALUOp_EX;

    wire [6:0] opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [31:0] NPC, NPC_wire, PCA4, PCA4_wire;
    wire [31:0] in_ins, out_ins, RD;
    wire [4:0] rs1, rs2, rd;
    wire [11:0] Imm12, Offset;
    wire [31:0] Imm32;
    wire [20:1] Offset20;
    wire [4:0] WR;

    wire [31:0] RD1, RD2, RD1_r, RD2_r;
    wire [31:0] A, B, ALU_result_r;

    wire [31:0] actual_in_ins, final_next_pc;
    wire [31:0] true_RD1, true_RD2;
    wire [31:0] forwardA_data, forwardB_data;
    wire [4:0] rd_EX;
    wire [31:0] PC_EX;
    wire [11:0] Offset_EX;
    wire [20:1] Offset20_EX;
    wire [31:0] Imm32_EX;
    wire [31:0] RD2_MEM;
    wire [4:0] WR_WB;
    wire [31:0] ALU_result_WB, DR_WB, PCA4_WB;
    wire load_use_stall;
    wire actual_PCWrite;
    wire actual_IRWrite;
    wire RFWrite_WB;
    wire ALUSrcA_EX;

    wire DMCtrl_MEM;

    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
        .PCWrite(PCWrite), .InsMemRW(InsMemRW), .IRWrite(IRWrite), .RFWrite(RFWrite), .DMCtrl(DMCtrl),
        .ExtSel(ExtSel), .ALUOp(ALUOp), .ALUSrcA(ALUSrcA), .NPCOp(NPCOp), .ALUSrcB(ALUSrcB),
        .WDSel(WDSel), .RegSel(RegSel), .rs1(rs1), .rs2(rs2), .rd(rd), .PC(PC), .in_ins(in_ins),
        .out_ins(out_ins), .Imm32(Imm32), .Offset(Offset), .Offset20(Offset20),
        .RD1(RD1), .RD2(RD2), .RD1_r(RD1_r), .RD2_r(RD2_r), .ALU_result_r(ALU_result_r), .RD(RD), .WR(WR), .WD(WD),
        .PCA4_wire(PCA4_wire), .NPC_wire(NPC_wire),
        .PC_EX(PC_EX), .rd_EX(rd_EX), .Imm32_EX(Imm32_EX), .Offset_EX(Offset_EX), .Offset20_EX(Offset20_EX),
        .ALUSrcA_EX(ALUSrcA_EX), .NPCOp_EX(NPCOp_EX), .ALUSrcB_EX(ALUSrcB_EX),
        .RegSel_EX(RegSel_EX), .ALUOp_EX(ALUOp_EX),
        .DMCtrl_MEM(DMCtrl_MEM), .RD2_MEM(RD2_MEM), .WR_WB(WR_WB), .RFWrite_WB(RFWrite_WB),
        .WDSel_WB(WDSel_WB), .ALU_result_WB(ALU_result_WB), .PCA4_WB(PCA4_WB),
        .DR_WB(DR_WB),
        .forwardA_data(forwardA_data), .forwardB_data(forwardB_data), .final_next_pc(final_next_pc),
        .load_use_stall(load_use_stall),
        .actual_in_ins(actual_in_ins), .true_RD1(true_RD1), .true_RD2(true_RD2),
        .out_opcode(opcode), .out_Funct7(Funct7), .out_Funct3(Funct3),
        .out_rs1(rs1), .out_rs2(rs2), .out_rd(rd),
        .out_Imm12(Imm12), .out_Offset(Offset), .out_Offset20(Offset20),
        .actual_PCWrite(actual_PCWrite), .actual_IRWrite(actual_IRWrite)
    );

    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(actual_PCWrite), .NPC(final_next_pc), .PC(PC)
    );

    NPC U_NPC (
        .NPCOp(NPCOp_EX), .Offset12(Offset_EX), .Offset20(Offset20_EX), .PC(PC_EX), .rs({ALU_result[31:1], 1'b0}), .PCA4(PCA4_wire), .NPC(NPC_wire)
    );

    IM U_IM (
        .InsMemRW(InsMemRW), .clk(clk), .addr(PC[11:2]), .Ins(in_ins)
    );

    IR U_IR (
        .clk(clk), .IRWrite(actual_IRWrite), .in_ins(actual_in_ins), .out_ins(out_ins)
    );

    RF U_RF (
        .RR1(rs1), .RR2(rs2), .WR(WR_WB), .WD(WD), .clk(clk), .RFWrite(RFWrite_WB), .RD1(RD1), .RD2(RD2)
    );

    Flopr U_A (
        .clk(clk), .rst(rst), .in_data(true_RD1), .out_data(RD1_r)
    );

    Flopr U_B (
        .clk(clk), .rst(rst), .in_data(true_RD2), .out_data(RD2_r)
    );

    EXT U_EXT (
        .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
    );

    MUX_3to1 U_MUX_3to1 (
        .X(rd_EX), .Y(5'd0), .Z(5'd31), .control(RegSel_EX), .out(WR)
    );

    MUX_2to1_A U_MUX_2to1_A (
        .X(forwardA_data), .Y(5'b0), .control(ALUSrcA_EX), .out(A)
    );

    MUX_3to1_B U_MUX_3to1_B (
        .X(forwardB_data), .Y(Imm32_EX), .Z(Offset_EX), .control(ALUSrcB_EX), .out(B)
    );

    ALU U_ALU (
        .A(A), .B(B), .ALUOp(ALUOp_EX), .zero(zero), .ALU_result(ALU_result)
    );

    Flopr U_ALUOut (
        .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
    );

    DM U_DM (
        .Addr(ALU_result_r[11:2]), .WD(RD2_MEM), .DMCtrl(DMCtrl_MEM), .clk(clk), .RD(RD)
    );

    MUX_3to1_LMD U_MUX_3to1_LMD (
        .X(ALU_result_WB), .Y(DR_out), .Z(PCA4_WB[29:0]), .control(WDSel_WB), .out(WD)
    );

    assign DR_out = DR_WB;
endmodule
