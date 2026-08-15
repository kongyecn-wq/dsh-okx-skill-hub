# dsh-okx-skill-hub

<p align="center">
  <img src="docs/banner.png" alt="dsh-okx-skill-hub" width="640">
</p>

OKX 官方 Agent Skills 技能库 —— 为 **DeepSeek Harness (DSH)** 适配的即插即用技能集合。

> 本仓库把 OKX 官方 `okx-cex-market` 技能原样移植进 DSH 生态，并提供 **纯技能目录** 与 **dsh-plugin 插件** 双通道安装。

## 这是什么

[OKX Agent Skills](https://github.com/okx/agent-skills) 是 OKX 官方的即插即用 AI Agent 技能库，通过单个 `okx` CLI 让任意 AI Agent 查询行情、管理持仓、运行网格/定投机器人，无需自行对接 API。本仓库将这些官方技能适配到 DeepSeek Harness 的技能体系（`SKILL.md` 目录束格式），让 DSH 用户开箱即用。

**已收录技能：**

| 技能 | 说明 | 安装 | 需 API Key |
|---|---|---|---|
| [`okx-cex-market`](skills/okx-cex-market/SKILL.md) | 行情数据：价格/ticker/订单簿/K线/资金费率/未平仓/技术指标（RSI、MACD、EMA、布林带、KDJ、SuperTrend、AHR999、BTC 彩虹等 70+） | ✅ 已收录 | ❌ 无需（纯只读公开数据） |
| `okx-cex-portfolio` | 账户余额/持仓 | 🚧 待收录（欢迎 PR） | ✅ 需要 |
| `okx-cex-trade` | 下单/撤单 | 🚧 待收录（欢迎 PR） | ✅ 需要 |
| `okx-cex-bot` | 网格/定投机器人 | 🚧 待收录（欢迎 PR） | ✅ 需要 |

## 为什么适配 DeepSeek Harness

DSH 的技能格式与 OKX 官方技能**完全同构**（`<技能名>/SKILL.md` + 头信息 `name`/`description` + `references/` 资源目录），因此**零改动的直接复制**即可被 DSH 发现、加载和执行：

| 项目 | DSH 要求 | OKX 官方技能现状 |
|---|---|---|
| 目录结构 | `<name>/SKILL.md`（单层） | `skills/okx-cex-market/SKILL.md` ✅ |
| 头信息 | `name`（短横线命名）+ `description` | `name: okx-cex-market` + `description` ✅ |
| 资源引用 | `{baseDir}/references/...` 按需加载 | `references/*.md` 5 个命令参考 ✅ |
| 版本/来源 | 可选 `metadata` | `_meta.json`（含官方 sha256 签名）✅ |

## 安装

### 方式一：纯技能目录（零依赖，推荐先试）

```bash
# 用户级（全会话生效，所有 profile）
git clone https://github.com/kongyecn-wq/dsh-okx-skill-hub.git
cp -r dsh-okx-skill-hub/skills/okx-cex-market ~/.dsh/skills/
cp -r dsh-okx-skill-hub/skills/_shared ~/.dsh/skills/

# 或项目级（跟随仓库走，仅该项目会话可见）
cp -r dsh-okx-skill-hub/skills/okx-cex-market <项目根>/.dsh/skills/
cp -r dsh-okx-skill-hub/skills/_shared <项目根>/.dsh/skills/
```

Windows 用户直接运行：

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1          # 用户级
powershell -ExecutionPolicy Bypass -File install.ps1 -Project  # 项目级
```

macOS/Linux 用户直接运行：

```bash
./install.sh            # 用户级
./install.sh --project  # 项目级
```

### 方式二：dsh-plugin 插件（一条命令，可卸载）

```bash
git clone https://github.com/kongyecn-wq/dsh-okx-skill-hub.git
cd dsh-okx-skill-hub
dsh plugin --profile web add .          # 安装到 web profile
# 或仓库插件格式：
dsh plugin --profile web add kongyecn-wq/dsh-okx-skill-hub#main&path:/.dsh-plugin
```

插件会注册一个独立的技能提供者 `okx-hub`，只暴露本仓库 `skills/` 目录里的技能，不污染你的用户/项目技能根。卸载：

```bash
dsh plugin --profile web remove dsh-okx-skill-hub
```

### 安装 `okx` CLI（技能运行时依赖）

```bash
npm install -g @okx_ai/okx-trade-cli
okx market ticker BTC-USDT   # 验证
```

> 行情类命令全部只读、无需 API Key。交易类技能（portfolio/trade/bot）需要 `OKX_API_KEY` / `OKX_SECRET_KEY` / `OKX_PASSPHRASE`（或 `okx auth login` 登录）。

## 使用示例

装好后直接对 DSH 说：

- 「BTC 现在多少钱？」→ `okx market ticker BTC-USDT`
- 「看下 ETH 的 4 小时 K 线」→ `okx market candles ETH-USDT --bar 4H`
- 「BTC-USDT 永续的资金费率是多少」→ `okx market funding-rate BTC-USDT-SWAP`
- 「RSI、MACD 帮我看看 BTC 日线」→ `okx market indicator rsi/macd BTC-USDT`
- 「哪些合约 24 小时涨幅最大」→ `okx market filter --instType SWAP --sortBy chg24hPct`

## 仓库结构

```
dsh-okx-skill-hub/
├── skills/                          # ① 纯技能目录通道（复制即用）
│   ├── _shared/preflight.md         #    OKX CLI 预检（官方共享文件）
│   └── okx-cex-market/              #    官方技能原样移植
│       ├── SKILL.md                 #    主技能（头信息 + 命令索引）
│       ├── _meta.json               #    官方签名元数据（sha256 可校验）
│       └── references/              #    5 个命令参考文档
├── .dsh-plugin/                     # ② 插件通道（dsh plugin add）
│   ├── package.json                 #    仓库插件包清单
│   └── cordis.patch.yml             #    patch：注册 okx-hub 技能提供者
├── package.json                     #    npm 插件清单（dsh.bundle）
├── install.ps1 / install.sh         #    一键安装脚本
└── docs/ADAPTATION.md               #    适配与实测记录
```

## 生态路线图

- [x] `okx-cex-market` 适配 + 双通道安装 + 本机实测
- [ ] 收录 `okx-cex-portfolio` / `okx-cex-trade` / `okx-cex-bot`（官方仓库同步）
- [ ] 技能自动更新脚本（跟随 OKX 官方版本，保留 sha256 校验）
- [ ] 挂 `dsh-plugin` / `dsh-skill` 话题，投稿精选列表与插件市场
- [ ] CI：官方签名校验 + 头信息结构检查

## 致谢与许可

- 技能内容版权归 [OKX](https://github.com/okx/agent-skills) 所有（MIT License），本仓库仅做 DSH 生态适配与分发。
- 包装代码（插件、脚本、文档）采用 MIT License。

## 相关链接

- [OKX Agent Skills](https://github.com/okx/agent-skills) · [OKX 技能市场](https://www.okx.com/zh-hans/agent-tradekit/skills/okx-cex-market)
- [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) · DSH 技能格式见官方仓库 `packages/skill/skill-filesystem`
