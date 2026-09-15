// riscv_defines.v
//
// Global `define macros shared by all RTL modules of the 6-stage pipeline CPU.
// Split from the original single-file riscv.v; content is unchanged.
//
`ifndef RISCV_DEFINES_V
`define RISCV_DEFINES_V


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

`endif // RISCV_DEFINES_V
