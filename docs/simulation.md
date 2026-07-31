# Simulation — 仿真说明

本节汇总仿真环境依赖、运行命令、常见问题与调试建议。来源：仓库中你上传的仿真说明文档（Word）。

工具（推荐）
- Icarus Verilog (iverilog) — 编译仿真
- vvp — 运行仿真
- GTKWave — 查看 VCD 波形

示例流程
1. 进入 sim/ 目录：
   cd sim
2. 编译：
   make build    # 或： iverilog -o tb.vvp ../rtl/*.v tb_top.v
3. 运行：
   make run      # 或： vvp tb.vvp
4. 查看波形：
   gtkwave out.vcd

常见问题
- 波形为空或信号未触发：确认 testbench 中 clk/reset 是否正确驱动
- SRAM 模型行为不明确：检查 IM/DM 的地址与宽度映射（Addr[11:2] 等）

我会把你上传的仿真 Word 中的命令/示例复制到本文件并补充 shell/make 示例脚本，确保一键复现。