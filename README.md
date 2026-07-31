# coach001‑CPU117 / 6‑stage pipeline (65nm process) — 项目总览

本仓库收录了我们在大学集创赛期间完成的 CPU 实现工程（6‑stage pipeline，65nm 工艺目标）的源代码、设计文档、仿真说明与答辩材料。该仓库以面向“找实习/展示作品集”为目标进行了整理：包含项目概述、源码目录、复现步骤、关键设计与调试日志，便于面试时演示或未来维护。

> 注意：当前仓库无演示视频；README 中使用的图片均为说明性占位图（assets/images/），你可以上传真实图片替换它们。

主要亮点
- 自研 6‑stage 流水线 CPU（支持 RISC‑V 子集）
- 流水线转发、冒险处理与简单分支预测（小型 BTB + BHT）实现
- 自定义 RTL（Verilog） + SRAM 模块仿真模板
- 仿真环境与测试用例（wave、testbench、仿真说明）

目录结构（高星仓库风格）
- README.md                    — 项目概览（本文件）
- LICENSE                      — MIT 许可证（默认）
- .gitignore                   — 忽略规则
- docs/                        — 详细文档：architecture, rtl_notes, simulation, devlog
- rtl/ 或 cpu/                 — Verilog 源码（按模块子目录）
- sim/                         — 仿真脚本、testbench、wave 文件样例
- examples/                    — 示例程序 / 汇编 / 测试用例
- assets/                      — 原始 PPT、技术文档、仿真说明原件、示意图

快速开始（复现仿真）
1. 克隆仓库：
   git clone https://github.com/zhx-997/a-6-stage-pipeline-65nm-process-implementation-CPU.git
   cd a-6-stage-pipeline-65nm-process-implementation-CPU
2. 切换到 docs/refactor 分支查看整理内容：
   git fetch origin
   git checkout docs/refactor
3. 安装仿真工具（示例：Icarus Verilog + GTKWave）
   - Ubuntu: sudo apt update && sudo apt install iverilog gtkwave
4. 运行 smoke 测试（示例）：
   cd sim
   make run
   gtkwave out.vcd

项目图片（占位）

![架构示意图](assets/images/architecture.png)

![流水线阶段示意](assets/images/pipeline.png)

联系方式
- GitHub: https://github.com/zhx-997

下一步我会做的事
- 根据你上传的 PPT/技术文档/Word/代码，填充 docs/*.md（architecture、rtl_notes、simulation、devlog），并把源码按模块归档到 rtl/ 与 sim/。
- 如果你同意，我会在本分支发起 Pull Request，方便你 review 后合并到 main。

如果需要我现在开始把所有文档与代码整理到这个分支并发 PR，请回复“现在发 PR”。