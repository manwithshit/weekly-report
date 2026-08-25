# 飞书连接器（lark-cli）

> 正式支持。所有个人数据命令显式 `--as user`，不要用 bot 身份代替，也不要为绕过权限静默换身份。

## 安装与授权
```bash
npx @larksuite/cli@latest install          # 仅当选了飞书且本机缺 lark-cli
lark-cli config init --new                 # 已有 CLI/应用配置则跳过，不重复 init
lark-cli auth login --domain <最小业务域> --no-wait --json
lark-cli auth status --json --verify       # 检查身份 / token / scope，不输出凭证
```
- 按所选来源组合**最小** `--domain`，别用 `--recommend` / `--domain all`。已有更广历史 scope 时，只能说“本次申请最小范围”，不能说“账号只有这些权限”；需要严格隔离用专门测试应用 / 账号，撤销旧授权由用户在官方页面自行决定。
- 命令返回授权 URL：当作不可修改字符串**原样展示**，用 `lark-cli auth qrcode <URL> --output <临时PNG>` 生成二维码，链接与二维码同时给。**结束当前轮**，请用户完成授权后回复“已授权”，不要同轮阻塞等待。
- 用户回复后执行 `lark-cli auth login --device-code <本次新生成 device_code>`；过期重新发起，**绝不复用**。
- **触达路径**：飞书是 Device Flow——未登录会先到飞书登录页，登录后**自动回授权页**；给出验证 URL 的同时用 `lark-cli auth qrcode <URL>` 出码，**用飞书 App 扫码最省步骤（直达授权）**。

## 采集
执行前先 `lark-cli <域> +<shortcut> --help` 核对参数（下表已按 lark-cli **1.0.81** 用 `--dry-run` 核验）。`--sender` 用本人 open_id（`lark-cli auth status` 里的 `openId`）。

| 来源 | 入口（1.0.81 实测） | 只保留的本人行为 |
|---|---|---|
| IM | `im +messages-search --sender <本人open_id> --start <ISO> --end <ISO> --as user --page-all`；`--is-at-me` 可单独捞“被@我”做弱证据/反例 | 本人发送 / 回复；高价值消息再补 chat / thread 上下文 |
| 文档 | ⚠️ **飞书无“按时间取我的文档”接口**（`docs +search` 只有关键词 `--query`）→ **文档源改用 WPS**（`kdocs list-latest-items` + `created_by`/`modified_by`，见 `wps.md`）。确在飞书且必须用：`docs +search --query <词> --as user`，再按 owner/时间事后过滤 | 创建 / 本人编辑为强；打开 / 共享不算产出 |
| 日历 | `calendar +agenda --start <ISO> --end <ISO> --as user`（默认 primary 日历） | 仅用于定位会议，不直接算成果 |
| 待办 | `task +get-my-tasks` / `task +get-related-tasks --page-all`，必要时 `task +search` 或查详情 | 本人创建 / 实质更新 / 完成；仅被分配不算进展 |
| 会议 | `vc +search` → 详情 / 参会快照 → `minutes +detail`（transcript / todo）；执行前先 `--help` 核对（本次未 dry-run 验证） | 真实参会、本人发言、决策、本人 Action Item；匿名发言待确认 |

无 `--page-all` 时读 `page_token` 手动翻页到底；达 page limit / 缺下一页 / 只回部分容器 / 返回 failure 字段，都视为不完整。所有命令支持 `--dry-run` 预览请求、`--jq` 过滤输出。
