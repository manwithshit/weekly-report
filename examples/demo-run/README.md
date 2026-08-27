# 演示数据（Demo Run）

> 出于隐私，仓库不放任何真实工作数据。这里是一份**完全虚构**的演示数据，用来说明 `weekly-report` 的产出结构，以及它的核心——**接触 ≠ 参与**：同样一堆工作痕迹里，只有你**真正主动做的**才进周报，被 @、被共享、被邀请、被分配的「只是接触过」全部被剔除。

## 文件

| 文件 | 说明 |
|---|---|
| [`sample-evidence.json`](sample-evidence.json) | 一周的「个人证据」数据（Skill 采集 + 归一化后的中间产物）。共 13 条：7 条**本人主动产出**、5 条**只是接触过**的反例、1 条需单独确认的**企微总结证据**。采集完整性在 `collection_runs` 中单独记录。 |
| [`sample-candidates.md`](sample-candidates.md) | Skill 成稿前给你复核的**候选清单**：每项有稳定 `candidate_id`；确认后形成 `approved_candidate_ids` 白名单，反例只留在「已排除 / 可能遗漏」。 |
| [`sample-weekly-report.md`](sample-weekly-report.md) | 最终生成的**本地周报草稿**（只含正例）。 |

## 怎么用它跑一遍（用于演示 / 录屏）

在你的 Agent（Codex / WorkBuddy 等）里，把 `sample-evidence.json` 当作「本周已采集的工作证据」，让它按周报流程做**个人归因 → 候选清单 → 成稿**：

```
这是本周的工作证据（演示数据）：examples/demo-run/sample-evidence.json
请按 weekly-report 的流程：做个人归因（接触≠参与），先给我编号候选清单，
我确认后再生成最终周报。
```

你会看到它把 5 条「只是接触过」的痕迹剔除或标为「可能遗漏」，只把你确认过的候选写进周报——这就是这个 Skill 和「飞书/钉钉自带周报表格堆活动条数」的根本区别。演示中的 Google Docs 是正例，企微「大圆」总结单列等待确认，不会被「确认候选」隐式批准。该总结的 `identity_verified=true` 只说明动作人 `ai_daiyuan` 可确认，不说明总结中的事项已证实属于当前用户。

证据结构还支持 `action_type=attended|updated`：`attended` 只证明到场，不单独算贡献；`updated` 只有实质更新才进候选。本演示未额外增加这两类事件，避免把核心闭环样例复杂化。

> 真实使用时，Skill 读的是你**自己账号里的真实数据**，且全程留在你本机。此处用虚构数据仅为公开演示。
