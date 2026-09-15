
`define INSTR_RTYPE_OP 7'b0110011  
`define INSTR_ITYPE_OP 7'b0010011  
`define INSTR_BTYPE_OP 7'b1100011  
`define INSTR_LW_OP    7'b0000011  
`define INSTR_SW_OP    7'b0100011  
`define INSTR_JAL_OP   7'b1101111  
`define INSTR_JALR_OP  7'b1100111  


`define INSTR_ADD_FUNCT  10'b0000000_000 
`define INSTR_SUB_FUNCT  10'b0100000_000 
`define INSTR_SUBU_FUNCT 6'b100011       
`define INSTR_AND_FUNCT  10'b0000000_111 
`define INSTR_OR_FUNCT   10'b0000000_110 
`define INSTR_XOR_FUNCT  10'b0000000_100 
`define INSTR_NOR_FUNCT  6'b100111       
`define INSTR_SLL_FUNCT  10'b0000000_001 
`define INSTR_SRL_FUNCT  10'b0000000_101 
`define INSTR_SRA_FUNCT  10'b0100000_101 
`define INSTR_SRLV_FUNCT 6'b000110       
`define INSTR_SRAV_FUNCT 6'b000111       
`define INSTR_SLLV_FUNCT 6'b000100       
`define INSTR_JR_FUNCT   6'b001000       

`define INSTR_BEQ_FUNCT  3'b000  
`define INSTR_BNE_FUNCT  3'b001  

`define INSTR_ADDI_FUNCT 3'b000  
`define INSTR_ORI_FUNCT  3'b110  
`define DEBUG 1

// NPC control signal
`define NPC_PC       2'b00
`define NPC_Offset12 2'b01
`define NPC_rs       2'b10
`define NPC_Offset20 2'b11
// A control signal
`define ALUSrcA_A    1'b0
`define ALUSrcA_sa   1'b1
// B control signal
`define ALUSrcB_B       2'b00
`define ALUSrcB_Imm     2'b01
`define ALUSrcB_Offset  2'b10
`define ALUSrcB_else    2'b11
// EXT control signal
`define ExtSel_ZERO     1'b0
`define ExtSel_SIGNED   1'b1
// ALU control signal
`define ALUOp_ADD 4'b0000     
`define ALUOp_SUB 4'b0001     
`define ALUOp_AND 4'b0010     
`define ALUOp_OR  4'b0011     
`define ALUOp_XOR 4'b0100     
`define ALUOp_SRA 4'b0111     
`define ALUOp_SLL 4'b1000     
`define ALUOp_SRL 4'b1001     
`define ALUOp_BR  4'b1010     
// RF control signal
`define RegSel_rd    2'b00
`define RegSel_rt    2'b01
`define RegSel_31    2'b10
`define RegSel_else  2'b11

`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC  2'b10
`define WDSel_Else    2'b11
// DM control signal
`define DMCtrl_RD    1'b0
`define DMCtrl_WR    1'b1


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



module ControlUnit(clk, rst, zero, opcode, Funct7,Funct3,
    PCWrite, InsMemRW, IRWrite, RFWrite, DMCtrl,
    ExtSel, ALUOp, ALUSrcA, NPCOp, ALUSrcB,
    WDSel, RegSel, rs1, rs2, rd, PC, in_ins,
    out_ins, Imm32, Offset, Offset20,
    RD1, RD2, RD1_r, RD2_r, ALU_result_r, RD, WR, WD,
    PCA4_wire, NPC_wire,

    PC_EX, rd_EX, Imm32_EX, Offset_EX, Offset20_EX,
    ALUSrcA_EX, NPCOp_EX, ALUSrcB_EX,
    RegSel_EX, ALUOp_EX,
    DMCtrl_MEM, RD2_MEM, WR_WB, RFWrite_WB,
    WDSel_WB, ALU_result_WB, PCA4_WB,
    DR_WB,
    forwardA_data, forwardB_data, final_next_pc,
    load_use_stall,
    actual_in_ins, true_RD1, true_RD2,

    out_opcode, out_Funct7, out_Funct3,
    out_rs1, out_rs2, out_rd,
    out_Imm12, out_Offset, out_Offset20,

    actual_PCWrite, actual_IRWrite);
    
input rst, clk, zero;
input [6:0] opcode, Funct7;
input [2:0] Funct3;
output reg PCWrite, InsMemRW, IRWrite, RFWrite, DMCtrl, ExtSel, ALUSrcA;
output reg [1:0] ALUSrcB, RegSel, NPCOp, WDSel;
output reg [3:0] ALUOp;
input [4:0] rs1, rs2, rd;
input [31:0] PC, in_ins, out_ins, Imm32;
input [11:0] Offset;
input [20:1] Offset20;
input [31:0] RD1, RD2, RD1_r, RD2_r, ALU_result_r, RD;
input [4:0] WR;
input [31:0] PCA4_wire, NPC_wire, WD;

output reg [31:0] PC_EX;
output reg [4:0] rd_EX;
output reg [31:0] Imm32_EX;
output reg [11:0] Offset_EX;
output reg [20:1] Offset20_EX;
output reg ALUSrcA_EX;
output reg [1:0] NPCOp_EX, ALUSrcB_EX;
output reg [1:0] RegSel_EX;
output reg [3:0] ALUOp_EX;
output reg DMCtrl_MEM;
output reg [31:0] RD2_MEM;
output reg [4:0] WR_WB;
output reg RFWrite_WB;
output reg [1:0] WDSel_WB;
output reg [31:0] ALU_result_WB;
output reg [31:0] PCA4_WB;
output reg [31:0] DR_WB;

output reg [31:0] forwardA_data;
output reg [31:0] forwardB_data;
output reg [31:0] final_next_pc;
output reg load_use_stall;
output reg [31:0] actual_in_ins;
output reg [31:0] true_RD1, true_RD2;

output wire [6:0] out_opcode;
output wire [6:0] out_Funct7;
output wire [2:0] out_Funct3;
output wire [4:0] out_rs1;
output wire [4:0] out_rs2;
output wire [4:0] out_rd;
output wire [11:0] out_Imm12;
output wire [11:0] out_Offset;
output wire [20:1] out_Offset20;

output reg actual_PCWrite;
output reg actual_IRWrite;


    reg valid_btb [0:7];
    reg [31:0] btb_tag [0:7];
    reg [31:0] btb_target [0:7];
    reg bht [0:7];
    integer i;
    reg [31:0] PC_ID;


    wire [2:0] fetch_idx = PC[4:2];
    wire btb_hit_IF = valid_btb[fetch_idx] && (btb_tag[fetch_idx] == PC);
    wire pred_taken_IF = btb_hit_IF && bht[fetch_idx];
    wire [31:0] pred_target_IF = btb_target[fetch_idx];
    
    wire [31:0] next_pc_seq = PC + 4;
    wire [31:0] predicted_npc = pred_taken_IF ? pred_target_IF : next_pc_seq;

  
    reg pred_taken_ID, pred_taken_EX;
    reg [31:0] pred_target_ID, pred_target_EX;
    reg [31:0] next_pc_seq_ID, next_pc_seq_EX;


    reg [4:0] rs1_EX, rs2_EX;
   
    reg [6:0] opcode_EX; reg [2:0] Funct3_EX;
    reg RFWrite_EX, DMCtrl_EX;
    reg [1:0] WDSel_EX;

 
    reg [31:0] PCA4_MEM; reg [4:0] WR_MEM; reg RFWrite_MEM;
    reg [1:0] WDSel_MEM;
  
    reg [31:0] PCA4_MEM2; 
    reg [4:0] WR_MEM2; 
    reg RFWrite_MEM2; 
    reg [1:0] WDSel_MEM2;
    reg [31:0] ALU_result_MEM2;

    
    reg valid_IR;
    always @(posedge clk or posedge rst) begin
        if (rst) valid_IR <= 1'b0;
        else valid_IR <= 1'b1;
    end
    wire [31:0] safe_out_ins = valid_IR ? out_ins : 32'h00000013;

   
    assign out_opcode = safe_out_ins[6:0];
    assign out_Funct3 = safe_out_ins[14:12];
    assign out_Funct7 = safe_out_ins[31:25];
    assign out_rs1    = safe_out_ins[19:15];
    assign out_rs2    = safe_out_ins[24:20];
    assign out_rd     = safe_out_ins[11:7];
    assign out_Imm12  = safe_out_ins[31:20];
    assign out_Offset20 = {safe_out_ins[31], safe_out_ins[19:12], safe_out_ins[20], safe_out_ins[30:21]};
    assign out_Offset = (out_opcode == `INSTR_BTYPE_OP) ? {safe_out_ins[31], safe_out_ins[7], safe_out_ins[30:25], safe_out_ins[11:8]} : 
                        ((out_opcode == `INSTR_SW_OP) ? {safe_out_ins[31:25], safe_out_ins[11:7]} : out_Imm12);

    
    wire uses_rs1 = (out_opcode == `INSTR_RTYPE_OP) || (out_opcode == `INSTR_ITYPE_OP) || (out_opcode == `INSTR_LW_OP) || (out_opcode == `INSTR_SW_OP) || (out_opcode == `INSTR_BTYPE_OP) || (out_opcode == `INSTR_JALR_OP);
    wire uses_rs2 = (out_opcode == `INSTR_RTYPE_OP) || (out_opcode == `INSTR_SW_OP) || (out_opcode == `INSTR_BTYPE_OP);

   
    wire is_beq = (opcode_EX == `INSTR_BTYPE_OP) && (Funct3_EX == 3'b000);
    wire is_bne = (opcode_EX == `INSTR_BTYPE_OP) && (Funct3_EX == 3'b001);
    wire is_jal_EX = (opcode_EX == `INSTR_JAL_OP);
    wire is_jalr_EX = (opcode_EX == `INSTR_JALR_OP);
    
    wire is_branch_EX = (opcode_EX == `INSTR_BTYPE_OP) || is_jal_EX || is_jalr_EX;
    
    wire actual_taken_EX = (is_beq && zero) || (is_bne && !zero) || is_jal_EX || is_jalr_EX;
    wire [31:0] actual_target_EX = NPC_wire;
    
    wire branch_mispredict_EX = is_branch_EX && (
        (pred_taken_EX != actual_taken_EX) ||
        (actual_taken_EX && (pred_target_EX != actual_target_EX))
    );
    wire [31:0] correct_pc_EX = actual_taken_EX ? actual_target_EX : next_pc_seq_EX;


    wire IF_ID_flush = branch_mispredict_EX;
    wire ID_EX_flush = branch_mispredict_EX || load_use_stall;

    always @(*) begin
        load_use_stall = (opcode_EX == `INSTR_LW_OP) && (rd_EX != 5'b0) &&
                         ((uses_rs1 && (rd_EX == out_rs1)) || (uses_rs2 && (rd_EX == out_rs2)));

        actual_PCWrite = PCWrite && !load_use_stall;
        actual_IRWrite = IRWrite && !load_use_stall;

        final_next_pc = branch_mispredict_EX ? correct_pc_EX : predicted_npc;
        actual_in_ins = IF_ID_flush ? 32'h00000013 : in_ins;

        true_RD1 = (RFWrite_WB && (WR_WB != 5'b0) && (WR_WB == out_rs1)) ? WD : RD1;
        true_RD2 = (RFWrite_WB && (WR_WB != 5'b0) && (WR_WB == out_rs2)) ? WD : RD2;
    end


    always @(*) begin
     
        if (RFWrite_MEM && (WR_MEM != 5'b0) && (WR_MEM == rs1_EX))
            forwardA_data = (WDSel_MEM == `WDSel_FromPC) ? PCA4_MEM : ALU_result_r;
        else if (RFWrite_MEM2 && (WR_MEM2 != 5'b0) && (WR_MEM2 == rs1_EX))
            forwardA_data = (WDSel_MEM2 == `WDSel_FromPC) ? PCA4_MEM2 :
                            (WDSel_MEM2 == `WDSel_FromMEM) ? RD : ALU_result_MEM2;
        else if (RFWrite_WB && (WR_WB != 5'b0) && (WR_WB == rs1_EX))
            forwardA_data = WD;
        else
            forwardA_data = RD1_r;

     
        if (RFWrite_MEM && (WR_MEM != 5'b0) && (WR_MEM == rs2_EX))
            forwardB_data = (WDSel_MEM == `WDSel_FromPC) ? PCA4_MEM : ALU_result_r;
        else if (RFWrite_MEM2 && (WR_MEM2 != 5'b0) && (WR_MEM2 == rs2_EX))
            forwardB_data = (WDSel_MEM2 == `WDSel_FromPC) ? PCA4_MEM2 :
                            (WDSel_MEM2 == `WDSel_FromMEM) ? RD : ALU_result_MEM2;
        else if (RFWrite_WB && (WR_WB != 5'b0) && (WR_WB == rs2_EX))
            forwardB_data = WD;
        else
            forwardB_data = RD2_r;
    end


    wire [2:0] update_idx = PC_EX[4:2];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<8; i=i+1) begin
                valid_btb[i] <= 1'b0; btb_tag[i] <= 32'b0; btb_target[i] <= 32'b0; bht[i] <= 1'b0;
            end
        end else if (is_branch_EX) begin
            valid_btb[update_idx] <= 1'b1;
            btb_tag[update_idx] <= PC_EX;
            btb_target[update_idx] <= actual_target_EX;
            bht[update_idx] <= actual_taken_EX;
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_ID <= 32'b0; pred_taken_ID <= 0; pred_target_ID <= 0; next_pc_seq_ID <= 0;
        end else if (IF_ID_flush) begin
            PC_ID <= 32'b0; pred_taken_ID <= 0; pred_target_ID <= 0; next_pc_seq_ID <= 0;
        end else if (!load_use_stall) begin
            PC_ID <= PC; pred_taken_ID <= pred_taken_IF; pred_target_ID <= pred_target_IF; next_pc_seq_ID <= next_pc_seq;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_EX <= 0; rs1_EX <= 0; rs2_EX <= 0; rd_EX <= 0;
            Imm32_EX <= 0; Offset_EX <= 0; Offset20_EX <= 0; opcode_EX <= 0; Funct3_EX <= 0;
            RFWrite_EX <= 0; DMCtrl_EX <= `DMCtrl_RD; ALUSrcA_EX <= 0; ALUSrcB_EX <= 0;
            RegSel_EX <= 0; NPCOp_EX <= `NPC_PC; WDSel_EX <= 0; ALUOp_EX <= `ALUOp_ADD;
            pred_taken_EX <= 0; pred_target_EX <= 0; next_pc_seq_EX <= 0;
        end 
        
        else 
        begin
        if (ID_EX_flush) begin
          
            PC_EX <= 0; rs1_EX <= 0; rs2_EX <= 0; rd_EX <= 0;
            Imm32_EX <= 0; Offset_EX <= 0; Offset20_EX <= 0; opcode_EX <= 0; Funct3_EX <= 0;
            RFWrite_EX <= 0; DMCtrl_EX <= `DMCtrl_RD; ALUSrcA_EX <= 0; ALUSrcB_EX <= 0;
            RegSel_EX <= 0; NPCOp_EX <= `NPC_PC; WDSel_EX <= 0; ALUOp_EX <= `ALUOp_ADD;
            pred_taken_EX <= 0; pred_target_EX <= 0; next_pc_seq_EX <= 0;
        end else begin
            PC_EX <= PC_ID; rs1_EX <= out_rs1; rs2_EX <= out_rs2; rd_EX <= out_rd;
            Imm32_EX <= Imm32; Offset_EX <= out_Offset; Offset20_EX <= out_Offset20; opcode_EX <= out_opcode; Funct3_EX <= out_Funct3;
            RFWrite_EX <= RFWrite; DMCtrl_EX <= DMCtrl; ALUSrcA_EX <= ALUSrcA; ALUSrcB_EX <= ALUSrcB;
            RegSel_EX <= RegSel; NPCOp_EX <= NPCOp; WDSel_EX <= WDSel; ALUOp_EX <= ALUOp;
            pred_taken_EX <= pred_taken_ID; pred_target_EX <= pred_target_ID; next_pc_seq_EX <= next_pc_seq_ID;
        end
    end
end

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PCA4_MEM <= 0; WR_MEM <= 0; RFWrite_MEM <= 0; DMCtrl_MEM <= `DMCtrl_RD; WDSel_MEM <= 0; RD2_MEM <= 0;
        end else begin
            PCA4_MEM <= PCA4_wire; WR_MEM <= WR; RFWrite_MEM <= RFWrite_EX;
            DMCtrl_MEM <= DMCtrl_EX; WDSel_MEM <= WDSel_EX; RD2_MEM <= forwardB_data;
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PCA4_MEM2 <= 0; WR_MEM2 <= 0; RFWrite_MEM2 <= 0; WDSel_MEM2 <= 0; ALU_result_MEM2 <= 0;
        end else begin
            PCA4_MEM2 <= PCA4_MEM; WR_MEM2 <= WR_MEM; RFWrite_MEM2 <= RFWrite_MEM;
            WDSel_MEM2 <= WDSel_MEM; ALU_result_MEM2 <= ALU_result_r;
        end
    end

  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            WR_WB <= 0; RFWrite_WB <= 0; WDSel_WB <= 0; ALU_result_WB <= 0; DR_WB <= 0; PCA4_WB <= 0;
        end else begin
            WR_WB <= WR_MEM2; RFWrite_WB <= RFWrite_MEM2; WDSel_WB <= WDSel_MEM2;
            ALU_result_WB <= ALU_result_MEM2; DR_WB <= RD; PCA4_WB <= PCA4_MEM2;
        end
    end

   
    always @(*) begin
        PCWrite = 1'b1; InsMemRW = 1'b1; IRWrite = 1'b1; RFWrite = 1'b0;
        DMCtrl = `DMCtrl_RD; ExtSel = `ExtSel_SIGNED; ALUSrcA = `ALUSrcA_A; ALUSrcB = `ALUSrcB_B;
        RegSel = `RegSel_rd; NPCOp = `NPC_PC; WDSel = `WDSel_FromALU; ALUOp = `ALUOp_ADD;

        case (out_opcode)
            `INSTR_RTYPE_OP: begin
                RFWrite = 1'b1;
                case ({out_Funct7, out_Funct3})
                    `INSTR_ADD_FUNCT:  ALUOp = `ALUOp_ADD;
                    `INSTR_SUB_FUNCT:  ALUOp = `ALUOp_SUB;
                    `INSTR_AND_FUNCT:  ALUOp = `ALUOp_AND;
                    `INSTR_OR_FUNCT:   ALUOp = `ALUOp_OR;
                    `INSTR_XOR_FUNCT:  ALUOp = `ALUOp_XOR;
                    `INSTR_SLL_FUNCT:  ALUOp = `ALUOp_SLL;
                    `INSTR_SRL_FUNCT:  ALUOp = `ALUOp_SRL;
                    `INSTR_SRA_FUNCT:  ALUOp = `ALUOp_SRA;
                    default: ALUOp = `ALUOp_ADD;
                endcase
            end
            `INSTR_ITYPE_OP: begin
                RFWrite = 1'b1; ALUSrcB = `ALUSrcB_Imm;
                case (out_Funct3)
                    3'b000: ALUOp = `ALUOp_ADD;
                    3'b110: ALUOp = `ALUOp_OR;
                    3'b001: ALUOp = `ALUOp_XOR;
                    3'b011: ALUOp = `ALUOp_SLL;
                    3'b101: ALUOp = (out_Funct7[5] == 1'b1) ? `ALUOp_SRA : `ALUOp_SRL;
                    default: ALUOp = `ALUOp_ADD;
                endcase
            end
            `INSTR_LW_OP: begin
                RFWrite = 1'b1; ALUSrcB = `ALUSrcB_Imm; WDSel = `WDSel_FromMEM; ALUOp = `ALUOp_ADD;
            end
            `INSTR_SW_OP: begin
                DMCtrl = `DMCtrl_WR; ALUSrcB = `ALUSrcB_Offset; ALUOp = `ALUOp_ADD;
            end
            `INSTR_BTYPE_OP: begin
                NPCOp = `NPC_Offset12; ALUSrcB = `ALUSrcB_B; ALUOp = `ALUOp_BR;
            end
            `INSTR_JAL_OP: begin
                RFWrite = 1'b1; NPCOp = `NPC_Offset20; WDSel = `WDSel_FromPC;
            end
            `INSTR_JALR_OP: begin
                RFWrite = 1'b1; NPCOp = `NPC_rs; ALUSrcB = `ALUSrcB_Imm;
                WDSel = `WDSel_FromPC; ALUOp = `ALUOp_ADD;
            end
            default: begin end
        endcase
    end
    endmodule


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


module DM( Addr,WD,clk,DMCtrl,RD);
    input [11:2] Addr;        
    input [31:0] WD;          
    input clk;                
    input DMCtrl;            
    output reg [31:0] RD;    

    reg [31:0] memory[0:1023];
    always @(posedge clk) begin 
        if (DMCtrl) begin
            memory[Addr] <= WD; 
        end
        else begin
            RD <= memory[Addr]; 
        end
    end 
    endmodule

module EXT(imm_in,ExtSel, imm_out);
    input [11:0] imm_in;
    input ExtSel;
    output reg[31:0] imm_out;

    always@(imm_in or ExtSel) begin
        case(ExtSel)
            `ExtSel_ZERO   :imm_out = {20'b0,imm_in[11:0]};
            `ExtSel_SIGNED :imm_out = {imm_in[11] ? 20'hfffff : 20'h00000 ,imm_in[11:0]};
            default        :imm_out = 32'b0;
        endcase
    end
    endmodule

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


module MUX_2to1_A(X, Y, control, out );
input [31:0] X;
input [4:0] Y;
input control;
output [31:0] out;

assign out = ( control == 1'b0 ? X : {27'b0, Y[4:0]});
endmodule



module MUX_3to1_B(X,Y,Z,control,out);
    input [31:0] X;
    input [31:0] Y;
    input [11:0] Z;
    input [1:0] control;
    output reg signed [31:0] out;

    always @ (X or Y or Z or control)  begin
        case(control)
            `ALUSrcB_B       : out = X;
            `ALUSrcB_Imm     : out = Y;
            `ALUSrcB_Offset  : out = $signed(Z);
            `ALUSrcB_else    : out = X;
        endcase
    end
    endmodule


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


module NPC(NPCOp, Offset12, Offset20, PC, rs, PCA4, NPC);
    input [1:0] NPCOp;
    input [12:1] Offset12;
    input [20:1] Offset20;
    input [31:0] PC;
    input [31:0] rs;
    output reg [31:0] PCA4;
    output reg [31:0] NPC;

    wire signed [12:0] Offset13;
    wire signed [20:0] Offset21;


    assign Offset13 = $signed({Offset12[12:1], 1'b0});
    assign Offset21 = $signed({Offset20[20:1], 1'b0});

    always@(*) begin
        case(NPCOp)
            `NPC_PC       : NPC = PC + 4;
            `NPC_Offset12 : NPC = $signed({1'b0, PC}) + $signed(Offset13);
            `NPC_rs       : NPC = rs;
            `NPC_Offset20 : NPC = $signed({1'b0, PC}) + $signed(Offset21);
            default       : NPC = PC + 4;
        endcase
        PCA4 = PC + 4;
    end
    endmodule

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

module RF(
    input  [4:0]  RR1,        
    input  [4:0]  RR2,        
    input  [4:0]  WR,         
    input  [31:0] WD,         
    input         RFWrite,    
    input         clk,        
    output [31:0] RD1,        
    output [31:0] RD2         
);

 
    reg [31:0] register [1:31];

    
    always @(posedge clk) begin

          if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;

            `ifdef DEBUG
         
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
    end



    assign RD1 = (RR1 == 5'd0) ? 32'h0 : register[RR1];
    assign RD2 = (RR2 == 5'd0) ? 32'h0 : register[RR2];

endmodule