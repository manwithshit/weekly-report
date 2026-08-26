# 谷歌连接器（gws · Google Workspace CLI）

> 正式支持。Gmail / Calendar / Drive / Docs 等，走官方组织的 `gws` CLI。**拿到的数据与“自己写最小 OAuth”完全相同**（同 API、同 scope），只是省了自建。⚠️ 非 Google 正式产品、活跃开发；**大陆网络下 OAuth 与 API 可达性务必先实测**。

## 安装
本地 CLI，需安装（和 lark-cli / kdocs-cli 一个门槛）：
```bash
npm install -g @googleworkspace/cli   # 或从 GitHub Releases 下二进制
gws --version
```
WorkBuddy 没有谷歌连接器，谷歌这一源在 WorkBuddy 里**也走本地 gws**（WorkBuddy 可运行 CLI）。

## 认证（OAuth，需要一个 GCP 项目）
任何 Google API 都要 OAuth 凭证，凭证必须挂在一个 **GCP（Google Cloud Platform）项目**下——这是硬性要求。`gws auth setup` 能帮你把项目和凭证建好（也可用 gcloud / 控制台）：
```bash
gws auth setup     # 建 / 接入 GCP 项目 + OAuth 凭证
gws auth login     # 打印授权 URL → 浏览器登录并勾选 scope
gws auth status
```
- 个人 @gmail 账号：OAuth 同意屏选 **External**；**只勾要的服务**（Gmail/Calendar/Drive 只读），别选 “all”（未验证/测试模式 scope 上限约 25）；敏感 scope 先用“测试用户”名单跑。
- 企业 Workspace 账号：可能被管理员限制外部 OAuth，需管理员放行；**只读你自己的数据仍走 per-user OAuth，不需要域级委派**（读全公司才需要 service account + domain-wide delegation + 超级管理员）。

## 采集（只读，用于周报）
执行前先 `gws <service> --help`。稳定入口：

| 来源 | 入口 | 归因看什么 |
|---|---|---|
| Gmail | `gws gmail +triage`；`gws gmail messages list --query 'in:sent after:YYYY/MM/DD'` | 本人**发出**、含承诺/交付的邮件 = 候选；纯抄送 / 通知不算 |
| 日历 | `gws calendar +agenda`（时区自动取自账号） | 本人真参加 / 发言才算；只被邀请不算（见 `attribution-rules.md`） |
| Drive / Docs | `gws drive` 列最近文件 + 看 `owners` / `lastModifyingUser` | 本人**创建 / 编辑 = 强**；别人共享给我 = 不算 |

命令为结构化 JSON 输出，接进 skill 的统一证据 + 归因管线（和飞书 / WPS 同一套）。`gws` 自带 `+weekly-digest`/`+standup-report` 工作流可参考，但本 Skill 的归因以 `attribution-rules.md` 为准。
