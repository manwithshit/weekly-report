# WPS 个人文档连接器（kdocs-cli）

> 正式支持。**仅 WPS 个人账号**；企业账号会 403，需改用企业版 [WPS365 CLI](https://github.com/wps365-open/cli)。

## 安装
WPS 官方 `kdocs-cli`（个人文档 CLI）。本机没有时用官方安装器（从 WPS 官方 CDN 下平台二进制，带 SHA256 校验，装到 `~/.local/bin/kdocs-cli`）；已装则 `kdocs-cli upgrade -y` 升级。`kdocs-cli version` 确认，`kdocs-cli --help` 看可用 service / action。

## 认证
```bash
kdocs-cli auth status        # 有 token 未必有效，务必配合下方只读验证
kdocs-cli auth login         # 浏览器 OAuth，用户在引导页用【个人账号】登录授权
```
Token 存系统钥匙链，Skill 不碰。企业号登录会持续等待或返回 `403001` → 停止重试，切个人号或改用 WPS365 企业 CLI。

**触达路径**：`auth login` 会自动打开 WPS 授权引导页（形如 `https://mcp-center.wps.cn/kdocs-auth/auth-guide?auth_code=...`），**把该 URL 原样给用户**。未登录先到 WPS 个人账号登录页，登录后回授权页。无原生二维码，以 URL 为入口。

**验证 token 真有效必须用只读调用**（`auth status` 的 `authenticated:true` 只代表“钥匙链里有 token”，可能已过期）：
```bash
kdocs-cli drive list-latest-items page_size=3 --output json   # code=0 才算通；code=400006=鉴权失败需重登
```

## 采集（周报用）
| 目的 | 命令 |
|---|---|
| 最近改动 / 访问的文档 | `kdocs-cli drive list-latest-items page_size=N --output json` |
| 读某篇正文（Markdown / 结构化） | `kdocs-cli drive read-file url=<链接>`（或 `file_id=` / `link_id=`，三选一，不要同时传） |
| 文档元信息（作者 / 改动人 / 时间） | 每条 FileInfo 带 `created_by`、`modified_by`、`mtime`、`version` |

读正文注意返回的 `data.warnings`（表格可能只读了默认工作表或首屏区域）。

## 归因映射（接触≠参与）
- `created_by` ＝ 本人 → `action_type=created`，**强证据**。
- `modified_by` ＝ 本人且非创建者 → `action_type=edited`，有实质编辑为**强**、否则**中**。
- 只出现在 `list-latest-items`，但 `created_by` / `modified_by` 都不是本人 → 仅“打开 / 被分享”，**弱证据或排除**，不计产出。

## 说明
- **数据全程在本地**：kdocs-cli 直连官方 API 取用户自己的文档，Skill 不缓存、不外传——这就是“数据存哪”的答案与隐私卖点。
- **没有字面 SQL 读取**：查询走 dbsheet（多维表格）`list-records`（带 filter）/ `records-search`，是基于 filter 的结构化查询，不是原生 SQL 语句。
- 限频纪律：遇 `429001` 立刻停到恢复时间，`429002` 熔断期零请求；不要连续换参 / 换子命令重试。
