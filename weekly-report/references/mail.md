# 邮箱连接器（himalaya，IMAP 只读）

> 正式支持 QQ / 163 / 126 等支持 IMAP 的邮箱。**只读邮件**，不要 SMTP，不发信 / 删信 / 移动 / 批量标记。

## 安装与配置
```bash
brew install himalaya           # 仅当选了邮箱且本机缺 himalaya
himalaya                        # 本机交互向导配置账户
```
用户在邮箱官网开启 IMAP / SMTP 并生成**客户端授权码**；授权码**只在本机交互提示里输入**，绝不粘到聊天、命令参数、录屏文本或仓库文件。

**触达路径（非 OAuth，没有授权页可自动弹）**：直接给用户其邮箱的设置页——QQ `https://mail.qq.com` → 设置 → 账户 → 开启 IMAP/SMTP → 生成授权码；163 `https://mail.163.com` 同理。这是"三级降级"里第 3 级的标准形态：到不了授权页，就把入口页 + 后续步骤讲清楚。自动发现失败时才用固定参数：
- QQ：`imaps://imap.qq.com:993`
- 163：`imaps://imap.163.com:993`

## 采集
```bash
himalaya account check                       # 先验证连通
himalaya --json envelope list                # 统一窗口内的信封
```
从返回的真实邮件 ID 读正文；只读用户确认需要的正文，不为摘要自动下载全部附件。归因：本人发出且含明确承诺 / 交付 ＝ 候选；纯通知 / 抄送不计本人产出。
