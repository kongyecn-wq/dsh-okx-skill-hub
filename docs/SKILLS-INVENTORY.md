# OKX 技能清单与数据能力盘点（规划用）

> 更新时间：2026-08-15 · 数据来源：OKX 官方 [agent-skills](https://github.com/okx/agent-skills) 仓库（github-main 分支，共 11 个技能）+ 本机实测
> 用途：技能收录规划、DSH 生态建设规划、交易策略能力规划

---

## 一、总览（11 个官方技能）

| # | 技能 | 类别 | 收录状态 | 需凭据 | 依赖 |
|---|---|---|---|---|---|
| 1 | `okx-cex-market` | 行情数据 | ✅ 已收录 | ❌ 无 | `okx` CLI |
| 2 | `okx-cex-portfolio` | 账户/持仓 | ✅ 已收录 | ✅ API Key | `okx` CLI |
| 3 | `okx-cex-trade` | 交易下单 | ✅ 已收录 | ✅ API Key | `okx` CLI |
| 4 | `okx-cex-smartmoney` | 聪明钱分析 | ✅ 已收录 | ✅ OAuth | `okx` CLI |
| 5 | `okx-sentiment-tracker` | 新闻/情绪 | ✅ 已收录 | ✅ API 凭据 | `okx` CLI |
| 6 | `okx-cex-bot` | 网格/DCA 机器人 | 🚧 未收录 | ✅ API Key | `okx` CLI |
| 7 | `okx-cex-auth` | 登录/认证 | 🚧 未收录 | 登录用 | `okx` CLI |
| 8 | `okx-cex-earn` | 赚币 | 🚧 未收录 | ✅ API Key | `okx` CLI |
| 9 | `earn-hunter` | 赚币机会监控 | 🚧 未收录 | ✅ API Key | `okx` CLI |
| 10 | `okx-cex-skill-mp` | 技能市场 | 🚧 未收录 | ✅ API Key | `okx` CLI |
| 11 | `okx-outcomes` | 预测市场 | 🚧 未收录 | ✅ API Key | `okx-outcomes` 独立二进制 |

---

## 二、已收录技能明细（5 个，本机实测可用）

### 1. okx-cex-market —— 行情数据（唯一免 Key）

**能拉什么：**
- 📈 价格：`ticker`（最新价/24h 高低/量/涨跌幅）、`tickers`（全品种）、`index-ticker`（指数价）
- 📊 K线：`candles`（OHLCV，1m~1M，可回溯 2021）、`index-candles`（指数K线）
- 📚 订单簿：`orderbook`（盘口深度，最多 400 档）
- 💹 衍生品数据：`funding-rate`（资金费率）、`mark-price`（标记价）、`price-limit`（涨跌停）、`open-interest`（未平仓）、`oi-history`（OI 历史）、`oi-change`（OI 变化扫描器）
- 🔍 筛选/发现：`filter`（多维筛选：涨幅/成交额/市值/资金费率/OI）、`instruments`（合约规格）、`instruments-by-category`（股票代币/金属/商品/外汇/债券）
- 🧮 技术指标：`indicator`（RSI/MACD/EMA/布林带/KDJ/SuperTrend/AHR999/BTC彩虹等 70+）、`indicator list`（指标清单）
- 🔄 其他：`trades`（最近成交）、`pair-spread`（配对价差统计）

**命令数**：19 条 · **实测**：✅ ticker/candles/funding-rate/RSI/filter 全部调通

---

### 2. okx-cex-portfolio —— 账户与持仓

**能拉什么：**
- 💰 余额：`balance`（交易账户）、`asset-balance`（资金账户）、`balance-all`（总资产快照+估值）
- 📦 持仓：`positions`（当前持仓+浮盈）、`positions-history`（历史平仓+已实现盈亏）
- 📋 账单：`bills`（资金流水/交易记录）
- 🏷️ 费率：`fees`（maker/taker 费率等级）
- ⚙️ 账户：`config`（UID/账户等级/持仓模式）、`max-size`/`max-avail-size`（最大可开量）、`max-withdrawal`（可提币）
- 🔄 操作：`transfer`（资金/交易账户互转）、`set-position-mode`（切换单向/双向持仓）

**命令数**：12 条（10 读 + 2 写）· **实测**：✅ balance/positions/config 全部调通

---

### 3. okx-cex-trade —— 交易下单（现货+永续+交割+期权+事件合约）

**能做什么：**
- 🟢 现货（SPOT）：`spot place/cancel/amend`、TP/SL（`spot algo place`）、追踪止损（`spot algo trail`）
- 🔷 永续（SWAP）：`swap place/cancel/amend/close`、杠杆（`swap leverage`）、TP/SL（`swap algo place`）、追踪止损、`swap positions/orders/fills`
- 🔷 交割（FUTURES）：同上全套
- 🎯 期权（OPTION）：`option instruments/greeks/place/cancel/amend/positions/fills`
- ⚡ 事件合约（EVENT）：`event browse/series/markets/place/cancel/orders`（YES/NO 预测）

**命令数**：约 61 条（spot 12 + swap 15 + futures 15 + option 10 + event 9）· **实测**：✅ 开仓/设杠杆/挂 TP/SL 全部调通（net 模式注意省略 `--posSide`）

---

### 4. okx-cex-smartmoney —— 聪明钱分析

**能拉什么：**
- 🏆 交易员排行：`trader-commands`（leaderboard、交易员收益/胜率）
- 👀 持仓跟踪：指定交易员当前持仓、入场价
- 📜 成交记录：交易员历史成交、平仓记录、已实现盈亏
- 🧭 共识信号：多空比、资金流向、仓位强度、信号历史

**命令数**：4 个 reference 模块（signal/trader/templates/workflows）· **凭据**：OAuth · **实测**：✅ 已发现，未实测命令（需 OAuth 登录）

---

### 5. okx-sentiment-tracker —— 新闻与情绪

**能拉什么：**
- 📰 新闻：`news latest`（最新）、`news by-coin`（币种新闻）、`news search`（关键词搜索）、`news detail`（全文）
- 💭 情绪：`news by-sentiment`（情绪筛选）、`news coin-sentiment`（币种情绪快照）、`news coin-trend`（情绪趋势）、`news sentiment-rank`（情绪排行）
- 📅 宏观：`news economic-calendar`（经济日历：NFP/CPI/GDP/FOMC/PMI）、`news list-regions`（日历区域）
- 🌐 数据源：`news platforms`（新闻源列表）

**命令数**：11 条 · **凭据**：API 凭据（OAuth2.1）· **实测**：✅ `news latest` 调通（返回实时新闻流，本机 API Key 模式可用）

---

## 三、未收录技能（6 个，规划参考）

### 6. okx-cex-bot —— 网格/DCA 机器人 ⭐ 优先
- 网格机器人：现货/合约/币本位网格（`bot grid create/stop/amend`）
- DCA 马丁：现货马丁/合约马丁（`bot dca ...`）
- 监控：`bot grid-orders`、盈亏监控
- **价值**：被动策略 + 与 trade/market 组合成"网格+行情"联动
- 凭据：API Key

### 7. okx-cex-auth —— 登录/认证
- `okx config init` 引导、OAuth 登录、API Key 配置
- **价值**：其他技能的前置依赖，收录后可做"一键认证"指引
- 凭据：无（本身是认证流程）

### 8. okx-cex-earn —— 赚币
- Simple Earn 活期/定期、Flash Earn、链上质押（staking/DeFi）、双币投资（DCD）、AutoEarn
- **价值**：闲置资金理财，与 portfolio 联动
- 凭据：API Key

### 9. earn-hunter —— 赚币机会监控
- 自动监控闪赚/定期/活期机会、推送通知、引导申购
- **价值**：通知型技能，可与 DSH 通知插件组合
- 凭据：API Key

### 10. okx-cex-skill-mp —— 技能市场
- 搜索/浏览/安装/下载交易技能、技能市场
- **价值**：技能生态入口，收录后可做"技能自更新"
- 凭据：API Key

### 11. okx-outcomes —— 预测市场
- YES/NO 事件合约（原 OKX Predictions）：事件列表/详情/下单
- **注意**：依赖**独立二进制 `okx-outcomes`**（非 `okx` CLI）
- 凭据：API Key

---

## 四、规划建议

### 收录优先级矩阵

| 优先级 | 技能 | 理由 |
|---|---|---|
| P0（下一批）| `okx-cex-bot` | 网格/DCA 与已收录的 market/trade 形成完整"分析→交易→自动化"闭环 |
| P0 | `okx-cex-auth` | 所有需凭据技能的前置，收录后体验闭环 |
| P1 | `okx-cex-earn` + `earn-hunter` | 闲置资金增值，差异化能力 |
| P1 | `okx-outcomes` | 独有预测市场，但需额外二进制，安装成本高 |
| P2 | `okx-cex-skill-mp` | 偏生态工具，价值最低 |

### 能力组合规划（已收录 5 个即可覆盖）

| 场景 | 技能组合 |
|---|---|
| 行情研判 | market（K线/指标/资金费率/OI）+ sentiment（新闻/情绪）|
| 策略信号 | market 指标 + smartmoney 聪明钱方向 + sentiment 情绪 |
| 执行交易 | trade（永续/现货+TP/SL）|
| 资金管理 | portfolio（余额/持仓/盈亏/划转）|
| 自动化 | + bot（网格/DCA，待收录）|

### 已上线实测结论

- 免 Key 链路：market ✅（全部命令可用）
- 交易链路：API Key ✅（开仓/杠杆/TP/SL 已实测成交）
- 新闻链路：✅（news 命令可用）
- 聪明钱链路：⏳ 待 OAuth 登录后实测
