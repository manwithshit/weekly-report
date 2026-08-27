# 个人证据归因规则（接触 ≠ 参与）· 单一来源

> 这是本 Skill 的核心判断规则。既由 SKILL.md 在**原始数据**上执行，也**原样嵌进外部 AI 的 prompt**（如企业微信「大圆」），让“已总结的结论”也按同一标准过滤。**改这里 = 全局生效。**

## 总则
先判「是不是本人主动」，再判「是不是真的产出」。把“只是接触过”的噪音降级或剔除。

## 逐条规则
- **群 / 群成员身份 ≠ 参与**：在一个群里、是群成员，不算参与；群里他人的消息不归本人。
- **被 @ ≠ 已处理**：被人 @ 但本人没有后续动作 → 弱证据，只标「可能遗漏」，不算成果。
- **主动消息才算**：本人在窗口内主动发送 / 回复的消息进候选；表情、撤回、无业务语义的短回复降级或排除。
- **文档：创建 / 编辑才算**：被分享、被打开、挂在我名下 ≠ 产出。本人**创建或实质编辑 = 强**；有内容的评论 = 中；仅改格式 / 错字 / 被动打开 = 降级。（能拿 `created_by`/`modified_by`、谷歌 `owners`/`lastModifyingUser` 时据此判。）
- **会议：发言 / 认领才算**：日历邀请 ≠ 参会；`attended` 只证明本人到场，本身不等于贡献。只有本人**发言 / 决策 / 给方案 / 处理风险 / 承担行动项**才升级。
- **任务：本人推进才算**：任务被分配给我 ≠ 本周进展。本人**创建 / 完成 / 实质评论**可进候选；`updated` 只有在状态、内容、交付物或明确下一步上有实质更新才进候选，空更新 / 仅改元数据降级。
- **拿不准一律 `pending`**：匿名发言、身份不确定、权限缺失、分页失败 → `pending`，禁止自动归因成「已完成」。

## 只留这几类“证据”
优先识别：**交付、推进、决策、风险处理、承诺、下一步**。不要用消息 / 会议 / 文档的**条数**代替产出。跨源同一事项互相印证以提高可信度。

## 证据语义：动作人 ≠ 当前用户关系
每条证据至少记录 `evidence_id`、`current_user_id`、`actor_id`、`actor_is_current_user`、`user_relation`、`action_type`、`event_time`、`ingested_at`。

- `actor_id` + `action_type` 回答“谁做了什么”。
- `current_user_id` + `user_relation` 回答“当前用户在这个事件里是什么关系”。
- `identity_verified` 只回答“`actor_id` 的身份是否可确认”；不回答“总结里的事项是否已证实属于当前用户”。已总结源仍用 `source_type=summary`、`evidence_level=medium` 和候选单列显式确认表达归因不确定性。
- 老板邀请我开会：`actor_id=u_boss`、`action_type=invited`、`user_relation=invitee`，不是我 `joined`。
- 老板给我分配任务：`actor_id=u_boss`、`action_type=assigned`、`user_relation=assignee`，只有后续发现我更新 / 完成 / 实质评论才生成我的新证据。
- `collection_complete` 是整次来源采集的状态，只放在 `collection_runs`，并同时记录 `stop_reason`；不复制到每条证据。

## 候选确认门禁
每个候选使用不随展示顺序或文案润色变化的 `candidate_id`，并保留能解析到原证据的非空 `source_evidence_ids`。用户补充的文字先归一为新的用户证据并生成 `evidence_id`，不允许无证据引用的候选进白名单。用户复核后形成 `approved_candidate_ids` 白名单。

- “确认”只批准候选区，不批准已排除、可能遗漏、`pending` 或数据缺口。
- 用户补充新事项时先生成新 `evidence_id` 和 `candidate_id`；修改时保留原 `candidate_id` 与原 `source_evidence_ids`，有新证据再追加。二者都必须进入 `approved_candidate_ids`，不得以自由文字直接进入终稿。
- 单列的总结证据先显示原 `evidence_id`。被用户确认后：若只补强既有候选，合并来源、保留原 `candidate_id` 并追加该 `evidence_id` 到 `source_evidence_ids`；若形成新事项，生成新 `candidate_id` 并写入该 `evidence_id`；对应 ID 仍必须进入 `approved_candidate_ids`。
- 本周进展 / 风险 / 待解决 / 下周计划这四类成稿内容的每条事实，只能来自 `approved_candidate_ids` 白名单候选。
- 已排除、可能遗漏、`pending` 只可放在数据说明 / 待确认提示，不得自动转成风险或计划。
- 风格校准只改写法，不得新增事实或把旧周报内容带入本周。

## 用作 prompt 时（给不能跑代码的 AI）
把上面「逐条规则」压成一句约束：**“只留我本人主动发起 / 推进 / 决策 / 承诺 / 交付的事；别人 @ 我没处理的、群里别人聊的、只是抄送 / 邀请 / 分配给我但没动的，都不要；拿不准就标待确认。”**
