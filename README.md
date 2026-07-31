# coach001‑CPU117 / 6‑stage pipeline (65nm process) — 项目总览

本仓库收录了我们在大学集创赛期间完成的 CPU 实现工程（6‑stage pipeline，65nm 工艺目标）的源代码、设计文档、仿真说明与答辩材料。该仓库以面向“找实习/展示作品集”为目标进行了整理：包含项目概述、源码目录、复现步骤、关键设计与调试日志，便于面试时演示或未来维护。

> 重要：我已在仓库中为原始材料保留了 assets/ 目录（PPT、Word、技术文档、仿真说明等）。请确认这些原件是否包含敏感信息（例如私钥、未脱敏的数据），如有请及时删除或告知我替换处理。

主要亮点
- 自研 6‑stage 流水线 CPU（支持 RISC‑V 子集）
- 流水线转发、冒险处理与简单分支预测（BTB+BHT）实现
- 自定义 RTL（Verilog） + SRAM 模块仿真模板
- 仿真环境与测试用例（wave、testbench、仿真说明）

推荐使用场景
- 面试/作品展示：README、docs/ 中的架构说明与 devlog 适合在面试中讲解设计动机与解决的问题
- 代码复现：仿真步骤已写在 docs/simulation.md，包含必备工具与运行命令
- 二次开发：模块化设计，便于拓展 ISA 或加入更完整的流水线/异常处理

目录结构（概览）
- README.md                    — 本文件
- LICENSE                      — 许可证（默认 MIT）
- docs/                        — 项目说明（architecture, simulation, devlog）
- rtl/ 或 cpu/                 — Verilog 源码（CPU、ALU、DM、IM、RF 等）
- sim/                         — 仿真脚本、testbench、波形/输入文件
- assets/                      — 原始答辩 PPT、技术文档（Word/PDF）、仿真说明原件
- examples/                    — 示例程序 / 汇编 / 测试用例

快速开始（在本机上复现仿真）
1. 克隆仓库：
   git clone https://github.com/zhx-997/a-6-stage-pipeline-65nm-process-implementation-CPU.git
2. 安装仿真工具（示例使用 Icarus Verilog + GTKWave）
   - Ubuntu: sudo apt install iverilog gtkwave
3. 进入仿真目录并运行测试：
   cd sim
   make run    # 或使用 iverilog + vvp 手动运行（详见 docs/simulation.md）
4. 查看波形：
   gtkwave out.vcd

仿真与复现实验（详情）
请参阅 docs/simulation.md：包含所需工具、命令、已知问题与调试建议。

开发日志（开发/调试要点）
请参阅 docs/devlog.md。该文件按时间线列出我们在开发过程中遇到的关键问题、定位方法与最终修复方案，便于在面试中展示解决问题的能力。

分支策略（建议）
- main / master — 发布/稳定版
- docs/refactor — 我为文档整理创建的分支（包含 README、docs/*）
- feature/* — 功能开发分支（例如 feature/pipeline‑hazard）
- ci — CI 配置分支（若需要）

贡献／许可
本仓库默认使用 MIT 许可（LICENSE 文件中有完整条款）。如需修改许可或移除/保密某些文件，请联系仓库所有者 zhx-997。

联系方式
- GitHub: https://github.com/zhx-997

下一步
我可以：
- 在仓库创建 docs/refactor 分支并在其中添加 docs/*.md（架构、仿真步骤、devlog）
- 把你上传的 PPT、Word、技术文档归档到 assets/ 并在 docs 中引用

如果你同意，我将继续在仓库创建分支并提交初稿（docs/、LICENSE、.gitignore）。