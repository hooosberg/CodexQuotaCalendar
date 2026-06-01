<p align="center">
  <img src="assets/icons/app-icon-256.png" alt="Codex Quota Calendar" width="128" height="128">
</p>

<h1 align="center">Codex Quota Calendar</h1>

<p align="center">
  <strong>把 Codex 每日/每周额度变成一个安静的 macOS 菜单栏日历。</strong>
  <br>
  今日份额 · 周剩余额度 · 本地历史记录 · 已公证 DMG
  <br>
  <a href="https://hooosberg.github.io/QuotaCalendar/">官网落地页</a> ·
  <a href="README.md">English</a> ·
  <a href="https://github.com/hooosberg/QuotaCalendar/releases/latest">下载</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014+-444.svg" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6.2-F05138.svg" alt="Swift 6.2">
  <img src="https://img.shields.io/badge/distribution-Notarized%20DMG-2e7d32.svg" alt="Notarized DMG">
  <img src="https://img.shields.io/badge/privacy-local%20only-1e88e5.svg" alt="Local only">
</p>

<p align="center">
  <a href="https://hooosberg.github.io/QuotaCalendar/">
    <img src="assets/screenshots/menu-popover.png" alt="Codex Quota Calendar 截图" width="760">
  </a>
</p>

> **下载：** [最新版已公证 DMG](https://github.com/hooosberg/QuotaCalendar/releases/latest)  
> Codex Quota Calendar 是独立工具，不隶属于 OpenAI。

Codex Quota Calendar 把不断变化的 Codex 使用额度转换成更容易理解的节奏：今天平均份额用了多少，本周还剩多少，当前速度是否舒适，什么时候可能用完。

它运行在 macOS 菜单栏里。没有服务器，没有分析统计，不做账号切换。授权 token 只保存在你的 Mac 本机。

## 为什么做

额度百分比本身不直观，日历更直观。

- **今日：** 今天平均份额已经用了多少。
- **本周：** 每周额度剩余多少，什么时候重置。
- **速度：** 使用最近本地记录点做平滑估计，即使最新轮询暂时没变化，也能估算节奏。
- **历史：** 只保留有限大小的本地记录点，不让日志无限增长。

## 功能

- SwiftUI 菜单栏 app。
- 今日份额圆环和本周可用日卡片。
- 周额度和 5 小时窗口统计。
- 本地滚动历史记录，让速度和预计用完时间更平稳。
- 10 分钟刷新周期。
- 12 种界面语言。
- 已签名、公证、staple 的 DMG 安装包。
- 内置官方用量页和更新入口。

## 隐私

| 项目 | 行为 |
|---|---|
| 账号 | 只读取本机 Codex 授权信息 |
| Token | 只保存在本机 |
| App 服务器 | 无 |
| 分析统计 | 无 |
| 第三方追踪 | 无 |
| 额度历史 | 本地有限大小滚动记录 |

完整说明：[隐私政策](privacy.html)

## 安装

1. 到 [Releases](https://github.com/hooosberg/QuotaCalendar/releases/latest) 下载最新版 DMG。
2. 打开 DMG。
3. 把 **Codex Quota Calendar** 拖到 **Applications**。
4. 从 Applications 或 Launchpad 启动。

发布版 DMG 已使用 Developer ID 签名，通过 Apple 公证，并完成 staple。

## 从源码运行

要求：

- macOS 14+
- Xcode Command Line Tools
- Swift 6.2+

本地运行：

```bash
./script/build_and_run.sh
```

运行测试：

```bash
swift test
```

如果你有 Developer ID 证书和 Apple 公证凭据，可以打包发布版：

```bash
./script/package_release.sh --notarize
```

发布凭据必须放在环境变量或被忽略的本地文件中。详见 [docs/release.md](docs/release.md)。

## 目录结构

```text
.
├── Sources/QuotaCalendar/      SwiftUI app 源码
├── Tests/QuotaCalendarTests/   单元测试
├── script/                     构建、图标、DMG、签名、公证脚本
├── docs/                       发布和打包文档
├── assets/                     官网和 README 图片素材
├── index.html                  GitHub Pages 落地页
└── privacy.html                隐私页
```

## 安全说明

本仓库明确排除：

- `.env*`
- Apple ID app-specific password
- App Store Connect API key
- `.p8`、`.p12`、`.cer`、provisioning profile
- 已构建的 DMG 和本地 release 输出

如果你发现仓库中误含敏感信息，请发邮件到 [zikedece@proton.me](mailto:zikedece@proton.me)。

## 开发者

由 [hooosberg](https://github.com/hooosberg) 构建。

联系邮箱：[zikedece@proton.me](mailto:zikedece@proton.me)
