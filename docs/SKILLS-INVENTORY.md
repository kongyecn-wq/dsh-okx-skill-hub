# OKX 技能完整清单（11 个官方技能 · 详细版）

> 更新时间：2026-08-15 · 数据来源：OKX 官方 [agent-skills](https://github.com/okx/agent-skills)（github-main）+ 本机实测
> 认证：OAuth（live+trade 全权限）· 网络：FastLink 全局模式 · CLI：@okx_ai/okx-trade-cli 1.4.2（官方原版）

---

## 总览

| # | 技能 | 类别 | 收录 | 凭据 | 依赖 | 实测 |
|---|---|---|---|---|---|---|
| 1 | okx-cex-market | 行情数据 | ✅ | 无 | okx CLI | ✅ 全通 |
| 2 | okx-cex-portfolio | 账户/持仓 | ✅ | OAuth/Key | okx CLI | ✅ 全通 |
| 3 | okx-cex-trade | 交易下单 | ✅ | OAuth/Key | okx CLI | ✅ 实盘成交 |
| 4 | okx-cex-smartmoney | 聪明钱分析 | ✅ | OAuth | okx CLI | ✅ 已通 |
| 5 | okx-sentiment-tracker | 新闻/情绪 | ✅ | OAuth/Key | okx CLI | ✅ 已通 |
| 6 | okx-cex-bot | 网格/DCA 机器人 | 🚧 | OAuth/Key | okx CLI | - |
| 7 | okx-cex-auth | 认证登录 | 🚧 | - | okx CLI | - |
| 8 | okx-cex-earn | 赚币 | 🚧 | OAuth/Key | okx CLI | - |
| 9 | earn-hunter | 赚币机会监控 | 🚧 | OAuth/Key | okx CLI | - |
| 10 | okx-cex-skill-mp | 技能市场 | 🚧 | OAuth/Key | okx CLI | - |
| 11 | okx-outcomes | 预测市场 | 🚧 | OAuth/Key | okx CLI + **okx-outcomes 二进制** | - |

---

## 一、已收录技能（5 个，详细命令）

### 1. okx-cex-market — 行情数据（免凭据）

**能力**：实时价格 / K线 / 订单簿 / 衍生品数据 / 市场筛选 / 70+ 技术指标 / 非加密资产

| 命令 | 功能 | 实测 |
|---|---|---|
| `okx market ticker <instId>` | 最新价、24h 高低/量/涨跌幅 | ✅ |
| `okx market tickers <SPOT/SWAP/FUTURES/OPTION>` | 全品种行情表 | ✅ |
| `okx market instruments --instType <t>` | 合约规格（ctVal/lotSz/minSz/杠杆上限）| ✅ |
| `okx market orderbook <instId> [--sz]` | 订单簿深度（最多 400 档）| - |
| `okx market candles <instId> [--bar] [--limit]` | OHLCV K线（1m~1M，回溯至 2021）| ✅ |
| `okx market index-candles <instId>` | 指数 K线（BTC-USD 等）| - |
| `okx market funding-rate <instId> [--history]` | 资金费率（SWAP）| ✅ |
| `okx market trades <instId>` | 最近成交 | - |
| `okx market mark-price --instType <t>` | 标记价格 | - |
| `okx market index-ticker` | 指数价格 | - |
| `okx market price-limit <instId>` | 涨跌停限价 | - |
| `okx market open-interest --instType <t>` | 未平仓合约 | - |
| `okx market instruments-by-category --instCategory <3-7>` | 股票代币/金属/商品/外汇/债券发现 | - |
| `okx market filter --instType <t> [多维筛选]` | 筛选器（涨幅/成交额/市值/资金费率/OI）| ✅ |
| `okx market oi-history <instId>` | OI 历史序列 | - |
| `okx market oi-change --instType <t>` | OI 变化扫描器（吸筹/派发）| - |
| `okx market indicator list` | 全部指标清单 | ✅ |
| `okx market indicator <rsi/macd/ema/...> <instId>` | 70+ 技术指标（RSI/MACD/EMA/BB/KDJ/SuperTrend/AHR999/彩虹）| ✅ |
| `okx market pair-spread <A> <B>` | 配对价差统计（均值回归用）| - |

---

### 2. okx-cex-portfolio — 账户与持仓

**能力**：余额 / 持仓 / 盈亏 / 账单 / 费率 / 划转 / 持仓模式

| 命令 | 功能 | 实测 |
|---|---|---|
| `okx account balance-all` | 总资产快照（交易+资金+估值）| ✅ |
| `okx account balance [ccy]` | 交易账户余额 | ✅ |
| `okx account asset-balance [--valuation]` | 资金账户 + 总估值 | ✅ |
| `okx account positions` | 当前持仓 + 浮动盈亏 | ✅ |
| `okx account positions-history` | 历史平仓 + 已实现盈亏 | - |
| `okx account bills` | 账户流水/交易记录 | - |
| `okx account fees --instType <t>` | 费率等级（maker/taker）| - |
| `okx account config` | UID/账户等级/持仓模式 | ✅ |
| `okx account max-size / max-avail-size` | 最大可开/可买量 | - |
| `okx account max-withdrawal` | 最大提币 | - |
| `okx account transfer` | 资金⇄交易账户划转 | - |
| `okx account set-position-mode` | 单向/双向持仓切换 | - |

---

### 3. okx-cex-trade — 交易下单（现货+永续+交割+期权+事件合约，约 61 命令）

**能力**：下单 / 撤单 / 改单 / 平仓 / 杠杆 / 止盈止损 / 追踪止损

**永续 SWAP（15 命令）**：`swap place`（下单）· `swap cancel` · `swap amend` · `swap close`（平仓）· `swap leverage`（杠杆）· `swap algo place`（TP/SL）· `swap algo trail`（追踪止损）· `swap algo amend/cancel` · `swap positions/orders/get/fills/get-leverage/algo orders`
**现货 SPOT（12 命令）**：`spot place/cancel/amend` · `spot algo place/amend/cancel`（TP/SL）· `spot algo trail` · `spot orders/get/fills/algo orders`
**交割 FUTURES（15 命令）**：与 SWAP 同构
**期权 OPTION（10 命令）**：`option instruments/greeks`（链+希腊值）· `option place/cancel/amend/batch-cancel` · `option orders/get/positions/fills`
**事件合约 EVENT（9 命令）**：`event browse/series/events/markets/place/amend/cancel/orders/fills`

> 实测：✅ 开仓/设杠杆/挂 TP/SL 全部成交（net 模式注意省略 `--posSide`）

---

### 4. okx-cex-smartmoney — 聪明钱分析（需 OAuth）

**能力**：牛人榜 / 交易员持仓跟踪 / 成交记录 / 多空共识信号

| 命令模块 | 功能 | 实测 |
|---|---|---|
| `okx smartmoney traders-by-filter --limit <n>` | 交易员排行（盈利/胜率/回撤）| ✅ |
| `okx smartmoney traders` | 交易员列表/详情 | - |
| `okx smartmoney positions` | 交易员当前持仓跟踪 | - |
| `okx smartmoney trades` | 交易员成交记录 | - |
| `okx smartmoney closed-positions` | 历史平仓 + 已实现盈亏 | - |
| `okx smartmoney consensus / signals` | 聚合共识信号 / 信号历史 | - |
| `okx smartmoney long-short-ratio` | 多空比 | - |

---

### 5. okx-sentiment-tracker — 新闻与情绪

**能力**：加密新闻 / 币种情绪 / 情绪排行 / 宏观经济日历

| 命令 | 功能 | 实测 |
|---|---|---|
| `okx news latest [--limit]` | 最新新闻流 | ✅ |
| `okx news by-coin` | 指定币种新闻 | - |
| `okx news search <kw>` | 关键词搜索（SEC/ETF/监管）| - |
| `okx news by-sentiment` | 情绪筛选新闻 | - |
| `okx news detail` | 文章全文 | - |
| `okx news coin-sentiment` | 币种情绪快照 | - |
| `okx news coin-trend` | 情绪趋势 | - |
| `okx news sentiment-rank` | 情绪排行 | - |
| `okx news platforms` | 新闻源列表 | - |
| `okx news economic-calendar` | 经济日历（NFP/CPI/GDP/FOMC/PMI）| - |
| `okx news list-regions` | 日历区域 | - |

---

## 二、未收录技能（6 个，详细命令）

### 6. okx-cex-bot — 网格/DCA 机器人

**能力**：网格策略（现货/合约/币本位）+ 马丁策略（现货/合约）

| 命令 | 功能 |
|---|---|
| `okx bot grid create` | 创建网格机器人 |
| `okx bot grid amend` | 修改区间/网格数/TP/SL |
| `okx bot grid stop` | 停止网格 |
| `okx bot grid positions` | 合约网格持仓（强平价/保证金率）|
| `okx bot grid liquidate-price` | 强平价估算 |
| `okx bot grid close-position` | 停止后剩余仓位平仓 |
| `okx bot grid orders / details / sub-orders` | 列表/详情+盈亏/网格成交明细 |
| `okx bot dca create / stop` | 创建/停止马丁机器人 |
| `okx bot dca orders / details / sub-orders` | 马丁列表/详情/周期明细 |

---

### 7. okx-cex-auth — 认证登录

**能力**：OAuth 登录 / 登出 / 状态 / auth 二进制管理

| 命令 | 功能 |
|---|---|
| `okx auth login --manual --site <global/eea/us/tr>` | OAuth 设备码登录（agent 友好）|
| `okx auth login --site <X>` | 交互式登录（终端阻塞）|
| `okx auth logout` | 登出 |
| `okx auth status --json` | 会话状态/权限 |
| `okx auth install / install-status / remove` | auth 二进制管理 |
| `okx config init` | **API Key 向导**（不做 OAuth）|

---

### 8. okx-cex-earn — 赚币

**能力**：活期/定期/闪赚/链上质押/双币赢/自动赚币（**不支持 demo，仅实盘**）

| 命令 | 功能 |
|---|---|
| `okx earn savings balance` | Simple Earn 活期余额 |
| `okx earn savings fixed-orders` | 定期订单 |
| `okx earn flash-orders` | 闪赚订单 |
| `okx earn onchain orders` | 链上赚币（质押/DeFi）|
| `okx earn dcd orders` | 双币投资（双币赢）|
| `okx earn autoearn` | 自动赚币 |

---

### 9. earn-hunter — 赚币机会监控

**能力**：自动监控赚币机会 + 推送通知 + 引导申购

- 平台检测（TG / 飞书 / 钉钉等通知渠道）
- 定时调度监控闪赚/定期/活期机会
- 推送通知并引导申购
- 配置：`platform.json`（调度/通知渠道/凭据）

---

### 10. okx-cex-skill-mp — 技能市场

**能力**：搜索/安装/管理 OKX 交易技能

| 命令 | 功能 |
|---|---|
| `okx skill search <kw>` | 关键词搜索技能 |
| `okx skill search --categories <id>` | 按分类筛选 |
| `okx skill categories` | 分类列表 |
| `okx skill add <name>` | 下载安装到全部 agent |
| `okx skill download <name>` | 下载包（zip/skill）|
| `okx skill list` | 本地已装技能 |
| `okx skill check <name>` | 检查更新 |
| `okx skill remove <name>` | 卸载 |
| `okx skill verify <name>` | 签名验证 |

---

### 11. okx-outcomes — 预测市场

**能力**：YES/NO 事件合约（原 OKX Predictions）
**注意**：需额外安装 `okx-outcomes` 二进制（Windows 从 github.com/okx/outcomes-cli/releases 下载）

| 命令 | 功能 |
|---|---|
| `okx outcomes data events / event / event-markets / market` | 事件列表/详情/市场 |
| `okx outcomes data trending` | 热门事件 |
| `okx outcomes data ticker / candles` | 结果资产行情/K线 |
| `okx outcomes search <kw>` | 关键词搜索（OAuth）|
| `okx outcomes clob price / prices / midpoint / spread / book` | CLOB 报价/深度 |
| `okx outcomes account balance` | 账户余额 |
| `okx outcomes trade ...` | 交易 YES/NO（需钱包绑定）|

---

## 三、能力组合与规划

| 场景 | 技能组合 |
|---|---|
| 行情研判 | market + sentiment |
| 策略信号 | market 指标 + smartmoney + sentiment |
| 执行交易 | trade（永续+TP/SL）|
| 资金管理 | portfolio |
| 被动策略 | + bot（待收录）|
| 闲置资金 | + earn / earn-hunter（待收录）|
| 技能自更新 | + skill-mp（待收录）|
| 预测市场 | + outcomes（待收录，需额外二进制）|

### 收录优先级

- **P0**：okx-cex-bot（补全自动化闭环）、okx-cex-auth（认证指引，流程已实测）
- **P1**：okx-cex-earn + earn-hunter（闲置资金增值）
- **P1**：okx-outcomes（独有预测市场，安装成本高）
- **P2**：okx-cex-skill-mp（生态工具）
