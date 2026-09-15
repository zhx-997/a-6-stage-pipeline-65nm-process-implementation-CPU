// files.f - file list for VCS (and other Verilog compilers)
// Lists all RTL sources (multi-module layout) + the testbench.
// Note: `include of rtl/riscv_defines.v is resolved via +incdir+../rtl.

+incdir+../rtl

../rtl/riscv_defines.v
../rtl/riscv.v
../rtl/ControlUnit.v
../rtl/ALU.v
../rtl/DM.v
../rtl/EXT.v
../rtl/Flopr.v
../rtl/IM.v
../rtl/IR.v
../rtl/MUX_2to1_A.v
../rtl/MUX_3to1_B.v
../rtl/MUX_3to1_LMD.v
../rtl/MUX_3to1.v
../rtl/NPC.v
../rtl/PC.v
../rtl/RF.v

riscv_sim.v
