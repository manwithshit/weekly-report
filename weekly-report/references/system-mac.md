# 系统日历 / 提醒（macOS EventKit，本地）

> macOS 本地读取，**数据不出机**。是“万能聚合器”：读用户加到系统里的所有账户（iCloud / Google / Exchange / CalDAV 订阅，含订阅进来的飞书日历）。iOS 的日历/提醒**走 iCloud 同步即间接覆盖**；纯 iOS 独占不同步的读不到。

## 授权
无授权页。首次读取会触发 macOS「日历」/「提醒事项」隐私权限弹窗（TCC），用户点允许即可。凭据由系统管理，Skill 不碰。

## 读取（只读）
优先用现成 CLI（没有就 `brew` 装）：
- 日历：`icalBuddy`（`brew install ical-buddy`）→ `icalBuddy -npn -nc eventsFrom:YYYY-MM-DD to:YYYY-MM-DD`；或 `osascript` 走 AppleScript、`swift` 直接调 EventKit。
- 提醒：`reminders`（`brew install keith/formulae/reminders-cli`）→ `reminders show-all`；或 `osascript` 读 Reminders。
- 兜底：`shortcuts run <含“查找日历事件/提醒”的快捷指令>`，无需 brew。

统一时间窗过滤：只保留 `start` / `due` / `completionDate` 落在本周窗口内的项。

## 归因（接触≠参与）
- 日历：邀请 ≠ 参会；日历事件只用来**定位**会议，成果仍以纪要/任务/文档佐证；RSVP=拒绝的排除；来自他人共享日历的事件不算本人产出。
- 提醒：本人**创建 / 完成 / 本周更新**的进候选；只是存在、未动的降级。

## 约束
只读；**不要新建 / 修改 / 删除**任何日历事件或提醒。
