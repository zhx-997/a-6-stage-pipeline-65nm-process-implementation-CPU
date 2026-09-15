// C:\Users\zhx de pc\Desktop\CPU117\.release\rtl\ControlUnit.v
//
// Module `ControlUnit` of the 6-stage pipelined RISC-V RV32I CPU.
// Split from the original single-file riscv.v; logic unchanged.
//
`include "riscv_defines.v"

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
