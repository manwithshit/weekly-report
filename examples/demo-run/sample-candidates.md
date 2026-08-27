# 候选清单（演示 · 生成前的一次复核）

> 由 `sample-evidence.json` 经「个人归因」后产出。**这是 Skill 在成稿前唯一一次交互**：每个候选有不随展示顺序变化的 `candidate_id`，你可回「确认 / 删 cand_... / 补充…… / 修改 cand_...……」。

本周候选工作（共 2 项）：

1. **[cand_2026-08-17_customer-ledger] [客户台账系统]** 确认三段式字段方案并推动联调 → 创建《字段规范 v2》→ 完成导入脚本自测（回填 2 个空值问题）→ 评审会发言并认领「异常 case 文档」→ 邮件向客户承诺**下周五（2026-08-28）**交付初版
   - 来源：飞书消息 + WPS 文档 + 飞书任务 + 妙记 + 邮件 + **Google Docs**（**跨源互证，强证据**）
   - `source_evidence_ids`: `ev_feishu_im_om_a1_sent`, `ev_wps_file_b2_created`, `ev_feishu_task_c3_completed`, `ev_feishu_meeting_d4_spoke`, `ev_mail_e5_sent`, `ev_google_doc_gdoc_1_edited`
   - 候选内风险 / 承诺：已承诺**下周五（2026-08-28）**交付初版，且已认领「补充异常 case 说明文档」，需在交付前补齐。
2. **[cand_2026-08-17_weekly-report-automation] [周报自动化]** 回复排期，确认本周做数据采集、下周做归因
   - 来源：飞书消息（中证据）
   - `source_evidence_ids`: `ev_feishu_im_om_f6_replied`

---

**已排除 / 可能遗漏（接触 ≠ 参与，未计入产出）：**

| 痕迹 | 为什么不算你的产出 |
|---|---|
| 被 @ 问进度但未回复 | 被 @ ≠ 已处理 → 弱证据，仅标「可能遗漏」 |
| 《视觉规范》被共享给我、仅打开未编辑 | `created_by` 是同事 → 共享 / 打开 ≠ 你的产出 |
| 被邀请「季度 OKR 对齐会」但未参加 | 邀请 ≠ 参会 → 排除 |
| 「整理竞品调研」被分配但本周无进展 | 分配 ≠ 进展 → 排除 |
| 「全员通知群」团建讨论 | 群成员 ≠ 参与，群里他人消息不归你 → 排除 |

**来自企微大圆总结（已总结源，请你确认哪些真是你做的）：**
- `ev_wecom_summary_daiyuan_1` 客户群推进台账联调排期 ＋ 向客户确认**下周五（2026-08-28）**交付 —— 中证据，与 `cand_2026-08-17_customer-ledger` 可能重叠；`identity_verified=true` 只表示总结动作人 `ai_daiyuan` 可确认，事项归因仍需显式确认，不在普通「确认」的批准范围内。若后续确认它只是补强现有事项，必须将该 `evidence_id` 追加到 `cand_2026-08-17_customer-ledger` 的 `source_evidence_ids` 并使该 ID 继续留在白名单；若形成新事项，则先生成新 `candidate_id`、将该 `evidence_id` 写入 `source_evidence_ids` 再批准。

> 本演示假设用户回复「确认」。校验上述 `source_evidence_ids` 均可解析后，形成白名单：`approved_candidate_ids = ["cand_2026-08-17_customer-ledger", "cand_2026-08-17_weekly-report-automation"]`。已排除 / 可能遗漏和待确认证据 `ev_wecom_summary_daiyuan_1` 均不在白名单中。
