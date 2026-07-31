# RTL Notes — RTL 模块说明

此文档为 RTL 源码（Verilog）逐模块的简要说明与接口参考，便于快速定位与二次开发。

目录（待填充）
- rtl/core/ (cpu 顶层模块 riscv.v)
  - riscv.v — 顶层连接 ControlUnit、ALU、RF、IM、DM 等模块
  - ControlUnit — 控制逻辑、流水线寄存器与分支预测实现
  - ALU — 算术逻辑单元，支持 SLL/SRL/SRA/ADD/SUB/AND/OR/XOR/BR 等操作
  - RF — 寄存器堆，写回时打印调试信息（在 DEBUG 模式下）
  - DM / IM — 使用仿真 SRAM 模块封装读写

每个模块建议说明内容
- 功能摘要
- 端口（输入/输出）与宽度说明
- 关键状态/寄存器
- 已知限制与 TODO

我将逐个读取源码并在本文件中补充以上内容（并在模块文件头部添加更详细注释）。