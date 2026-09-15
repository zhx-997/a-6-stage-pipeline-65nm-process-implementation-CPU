# Synth (Design Compiler)

This directory contains the synthesis script for the 6-stage pipeline CPU.

## Files

- `dc_synth.tcl` — Synopsys Design Compiler script (reconstructed from the
  design report, section 5.1). All server-specific paths are replaced with
  environment variables.

## Prerequisites

- Synopsys Design Compiler (`dc_shell`)
- TSMC 65nm LP standard cell library: `tcbn65lpwc.db` (worst-case ss corner,
  1.08 V, 125 °C), directory `tcbn65lp_220a`
- SRAM macro: `tsln65lpll2048x64m8_220a_ss1p08v125c.db` (2048 x 64-bit),
  directory `tsln65lpll2048x64m8_220a/SYNOPSYS`
- The RTL sources under `../rtl/`

## Usage

```bash
export LIB_PATH=/path/to/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_220a
export SRAM_LIB_PATH=/path/to/sram/tsln65lpll2048x64m8_220a/SYNOPSYS
export HDL_PATH=/path/to/this/repo/rtl
export INC_PATH=/path/to/this/repo/rtl

mkdir -p output
dc_shell -f dc_synth.tcl
```

## Key settings

| Setting | Value |
|---|---|
| Clock period | 5.75 ns (174 MHz) |
| Clock uncertainty | 0.25 ns |
| Input delay | 1.0 ns |
| Output delay | 0.5 ns |
| Compile | `compile_ultra -retime` |
| SRAM path group weight | 5.0 |

## Notes

- The original script (design report Listing 5) had a typo in the `set_input_delay`
  line; the semantics are restored here and annotated in the script.
- SRAM behavioral model (`tsln65lpll2048x64m8`) is excluded from analysis since
  it is proprietary IP and not part of this repository.
- Outputs (`riscv_out.v`, `riscv_out.sdc`, reports) are written to `output/`.
