# dc_synth.tcl
#
# Synopsys Design Compiler synthesis script for the 6-stage pipeline CPU.
# Reconstructed from the design report (section 5.1, Listing 5), with all
# server-specific paths replaced by placeholder environment variables so the
# script runs on any machine with a TSMC 65nm library.
#
# Target: TSMC 65nm LP (tcbn65lpwc, worst-case ss/1.08V/125C) + SRAM macro
#         ts1n65lpll2048x64m8 (2048 x 64-bit) for IM/DM.
# Clock:  5.75 ns (174 MHz), uncertainty 0.25 ns, retiming enabled.
#
# Usage:
#   dc_shell -f dc_synth.tcl
#
# Required environment variables:
#   LIB_PATH        standard cell NLDM directory (tcbn65lp_220a)
#   SRAM_LIB_PATH   SRAM macro NLDM directory (tsln65lpll2048x64m8_220a/SYNOPSYS)
#   HDL_PATH        RTL directory (this repo's rtl/)
#   INC_PATH        include dir (can be same as HDL_PATH)

# ==================== LIB / SRAM / HDL / INC ====================
set LIB_PATH       $::env(LIB_PATH)
set SRAM_LIB_PATH  $::env(SRAM_LIB_PATH)
set HDL_PATH       $::env(HDL_PATH)
set INC_PATH       $::env(INC_PATH)

set_app_var search_path [ list . $LIB_PATH $SRAM_LIB_PATH $HDL_PATH $INC_PATH]
set target_library "tcbn65lpwc.db tsln65lpll2048x64m8_220a_ss1p08v125c.db"
set link_library "* $target_library"

# Analyze all RTL files except the SRAM behavioral model (if present)
set all_v_files [ glob ${HDL_PATH}/*.v]
set filtered_v_files [ lsearch -all -inline -not -glob $all_v_files "*tsln65l*"]
analyze -format verilog $filtered_v_files
elaborate riscv

# ==================== CONSTRAINTS ====================
create_clock [get_ports clk] -name clk -period 5.75
set_clock_uncertainty 0.25 [get_clocks clk]

# Input delay 1.0 ns / output delay 0.5 ns (report Listing 5 line 19; the
# original had a typo, restoring the intended semantics: all inputs except clk,
# all outputs)
set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay 1.0 -clock clk [get_ports rst]
set_output_delay 0.5 -clock clk [all_outputs]

# SRAM path grouping with weight 5.0 (critical for this design)
group_path -name SRAM_TO_LOGIC -from [get_cells U_DM/memory] -weight 5.0 -critical_range 0.5
group_path -name LOGIC_TO_SRAM -to [get_pins U_DM/memory/A] -weight 5.0

# rst is a false path (async reset)
set_false_path -from [get_ports rst]

# Driving cell: all inputs except clk driven by INVD12
set_driving_cell -lib_cell INVD12 \
    [remove_from_collection [all_inputs] [get_ports clk]]

set_wire_load_selection_group "WireAreaLowkCon" -library "tcbn65lpwc"
set_wire_load_mode "segmented"

set_load 1 [all_outputs]

# ==================== COMPILE ====================
compile_ultra -retime

# ==================== POST-COMPILE CHECKS & REPORTS ====================
check_timing

write -format verilog -hierarchy -output ./output/riscv_out.v
write_sdc ./output/riscv_out.sdc

# Reports
report_timing -path full -delay max -nworst 10 > ./output/timing_report.rpt
report_area > ./output/area_report.rpt
report_qor > ./output/qor_report.rpt
