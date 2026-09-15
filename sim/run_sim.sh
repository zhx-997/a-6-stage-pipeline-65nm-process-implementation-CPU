#!/usr/bin/env bash
# run_sim.sh - compile and run the RTL simulation with Synopsys VCS + Verdi
#
# Reconstructed from the design report (section 4.1.2). The Verdi PLI paths
# were server-specific; they are replaced with $VERDI_HOME so the script runs
# on any machine where VCS/Verdi are installed.
#
# Usage:
#   cd sim
#   ./run_sim.sh            # compile + run + open Verdi GUI
#   ./run_sim.sh --no-gui   # compile + run without opening Verdi
set -e

: "${VERDI_HOME:?Please set VERDI_HOME (e.g. export VERDI_HOME=/path/to/Verdi)}"

GUI=1
[ "$1" = "--no-gui" ] && GUI=0

echo "==> Compiling with VCS ..."
vcs \
  -f ./files.f \
  -timescale=1ns/1ps \
  -full64 +vc +v2k -sverilog -debug_all \
  -LDFLAGS -Wl,--no-as-needed \
  -cm line+cond+tgl+fsm \
  -P "$VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab" \
     "$VERDI_HOME/share/PLI/VCS/LINUX64/pli.a" \
  +notimingchecks +nospecify \
  -o simv \
  | tee compile.log

echo "==> Running simulation ..."
if [ "$GUI" = "1" ]; then
  ./simv -gui=verdi
else
  ./simv
fi

echo "==> Done. Waveforms: riscv_sim.vcd"
