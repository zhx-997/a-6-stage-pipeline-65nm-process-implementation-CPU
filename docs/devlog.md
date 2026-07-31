# Devlog — 开发日志（模板）

本文件按时间线记录开发与调试中的关键事件，便于在面试中讲述问题定位与解决能力。

格式（示例）

## [202X‑XX‑XX] 初始化项目结构
- 完成顶层 riscv.v 框架，连接 ControlUnit、ALU、RF、IM、DM
- 编写基本的 ALU 与 RF 模块

## [202X‑XX‑XX] 实现流水线寄存器与转发
- 发现数据冒险导致错误写回，定位到 MEM/WB 写回控制
- 采用三层前递逻辑（MEM、WB 优先）解决数据冒险

## [202X‑XX‑XX] 分支预测与 BTB
- 实现 8-entry 直接映射 BTB（索引 PC[4:2]）和 BHT（一位预测）
- 在实际测试中发现 mispredict 导致 pipeline flush 相关 bug，修复策略：在 EX 阶段更新 BTB 和 BHT，并在 IF/ID 使用预测抑制指令写入

(后续：我会根据你的技术文档和答辩 PPT补充这些条目，并把每个事件关联到对应的 commit 或文件行号)