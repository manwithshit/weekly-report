# 钉钉连接器（dws）— 实验性

> ⚠️ 实验性。受企业管理员授权与租户权限限制，实际数据域可能读不到。读不到就标 `pending`，**不要假装配置完成，也不要切账号 / 组织绕过**。

## 安装与登录（经用户确认后）
优先可追溯的 Homebrew，不用 `curl | sh`：
```bash
brew tap DingTalk-Real-AI/dingtalk-workspace-cli https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli.git
brew install dingtalk-workspace-cli
dws auth login
```
GitHub 网络不通、且最初清单已声明 npm 兜底时，可用官方稳定包（不要 beta）：
```bash
npm install -g dingtalk-workspace-cli
```
装后先 `dws version` / `dws --help` 验证二进制，再单独进入登录。浏览器内选组织授权，用 `dws profile list` 记稳定的 `corpId:userId`（不以姓名作为身份键）。管理员未开 CLI / 权限不足 / 听记发言人无法实名映射 → 标 `pending`，安装成功不等于已获得企业数据权限。
