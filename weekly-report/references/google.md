# 谷歌连接器（gws · Google Workspace CLI）

> 正式支持。Gmail / Calendar / Drive / Docs 等，走官方组织的 `gws` CLI。**拿到的数据与“自己写最小 OAuth”完全相同**（同 API、同 scope），只是省了自建。⚠️ 非 Google 正式产品、活跃开发；**大陆网络下 OAuth 与 API 可达性务必先实测**。

## 安装
本地 CLI，需安装（和 lark-cli / kdocs-cli 一个门槛）：
```bash
npm install -g @googleworkspace/cli   # 或从 GitHub Releases 下二进制
gws --version
```
WorkBuddy 没有谷歌连接器，谷歌这一源在 WorkBuddy 里**也走本地 gws**（WorkBuddy 可运行 CLI）。

## 认证（OAuth · 一次性 · 最短路径）

> **别装 gcloud，别用 `gws auth setup`。** 实测教训：`gws auth setup` **既不自动建 GCP 项目、也不自动建 OAuth 客户端**——Google 硬性要求 OAuth 客户端必须在 Cloud Console UI 手动建。既然客户端怎么都得手建，就直接走下面这条：全程在浏览器点，不碰命令行装包。（当初为方案 B 去装 gcloud、踩 SIP/沙盒/tarball 一整段，全是绕路，见文末踩坑。）

**① 在 Cloud Console 建凭证（浏览器，你自己账号）**
1. 建 / 选一个 GCP 项目（免费，不涉计费）。
2. **APIs & Services → Enable APIs**：开启 **Gmail API**、**Drive API**。
3. **OAuth consent screen**：User Type = **External**，填 App name / support email；**把自己的 @gmail 加进 Test users**（测试模式必须，否则登录直接 `403 access_denied`——提前加省一个来回）。
4. **Credentials → Create credentials → OAuth client ID** → 应用类型选 **Desktop app** → 拿到 **Client ID / Secret**（可下载 `client_secret.json`）。

**② 把凭证交给 gws**
```bash
# 二选一：
mv ~/Downloads/client_secret_*.json ~/.config/gws/client_secret.json   # A. 放文件
export GOOGLE_WORKSPACE_CLI_CLIENT_ID=...  GOOGLE_WORKSPACE_CLI_CLIENT_SECRET=...   # B. 环境变量
```

**③ 登录并验证**
```bash
gws auth login --readonly -s drive,gmail   # 起本地 http://localhost:<port> 回跳，浏览器登录勾 Gmail/Drive 只读
gws auth status                            # 看 has_refresh_token / scopes
```
⚠️ `gws auth login` 打印的授权 URL **scope 是坏的**（gws bug，见踩坑 2），务必用手拼的干净 URL 打开。

- 个人 @gmail：consent 选 **External**；**只勾要的只读 scope**（Gmail/Drive readonly），别选 “all”（未验证/测试模式 scope 上限约 25）。
- 企业 Workspace：可能被管理员限制外部 OAuth，需放行；**只读自己数据走 per-user OAuth，不需要域级委派**（读全公司才要 service account + domain-wide delegation + 超管）。

## 采集（只读，用于周报）
执行前先 `gws <service> --help`。稳定入口：

| 来源 | 入口 | 归因看什么 |
|---|---|---|
| Gmail | `gws gmail +triage`；`gws gmail messages list --query 'in:sent after:YYYY/MM/DD'` | 本人**发出**、含承诺/交付的邮件 = 候选；纯抄送 / 通知不算 |
| 日历 | `gws calendar +agenda`（时区自动取自账号） | 本人真参加 / 发言才算；只被邀请不算（见 `attribution-rules.md`） |
| Drive / Docs | `gws drive` 列最近文件 + 看 `owners` / `lastModifyingUser` | 本人**创建 / 编辑 = 强**；别人共享给我 = 不算 |

命令为结构化 JSON 输出，接进 skill 的统一证据 + 归因管线（和飞书 / WPS 同一套）。`gws` 自带 `+weekly-digest`/`+standup-report` 工作流可参考，但本 Skill 的归因以 `attribution-rules.md` 为准。

## 实战踩坑（2026-08-27 macOS 实测，复用）

> 坑 1、3 只在你**误走 gcloud / `gws auth setup` 那条路**时才会撞上；按上面「最短路径」走可**整段避开**。坑 2、4、5 是 gws/gmail 本身的问题，正常用也会遇到。

**1.（避坑）别为 gws 去装 gcloud——`gws auth setup` 帮不上，还会被沙盒挡死**
`gws auth setup --project X --login` 走到第 4 步会因「OAuth 客户端必须控制台手建」停住；而 `brew install google-cloud-sdk` 在本机被 macOS 沙盒的 `sandbox-exec` 挡死（`Operation not permitted`，系统层 SIP 限制，跟授权无关）。结论：**gcloud 全程不需要**，直接走「最短路径」手建客户端。（当初实在要装 gcloud 的话，走官方 tarball、架构名是 `darwin-arm` 不带 64——但本 Skill 用不到。）

**2. `gws auth login` 报 `invalid_scope`**
`gws` 会把 userinfo scope 拼成非法格式（`auth.userinfo.email`，用点而非斜杠），Google 直接拒。只需 `drive.readonly` + `gmail.readonly` + `openid`，手工拼干净 URL（`client_id` / `redirect_uri` 端口取自 gws 打印的那条授权 URL）：
```
https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.readonly%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fgmail.readonly%20openid&access_type=offline&redirect_uri=http%3A%2F%2Flocalhost%3A<gws打印的端口>&response_type=code&client_id=<你的client_id>&prompt=select_account+consent
```

**3. `403 access_denied`＝OAuth 同意屏还在 Testing、你没加自己**
consent screen → **Audience → Test users** 里把自己的 @gmail 加进去，再重点授权链接即可（不用重建任何东西）。**在「最短路径」第 ①.3 步提前加就不会撞。**

**4. `gws` 把日志打到 stderr，会污染 JSON 解析**
启动会向 **stderr** 打印 `Using keyring backend: keyring`。若用 `2>&1` 混进 stdout，`json.load` 直接报错。采集务必分离：`gws ... --format json 2>/dev/null`。

**5. `gws` 不支持 `batchGet`**
`gws gmail users messages batchGet` 报 `unrecognized subcommand`（仅 `attachments` / `batchDelete`）。拉多封元数据要逐条 `gws gmail users messages get --params '{"id":"X","format":"metadata"}'`，可 `xargs -P 8` 并行（每条包 `timeout 20` 防卡死）。
