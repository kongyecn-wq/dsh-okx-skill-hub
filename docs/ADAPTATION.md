# 适配说明（OKX 官方技能 → DeepSeek Harness）

本文记录 `okx-cex-market` 从 OKX 官方 [agent-skills](https://github.com/okx/agent-skills) 适配进 DSH 的全部决策、改动与实测结果，供后续技能收录（portfolio/trade/bot）复用同一套流程。

## 1. 兼容性结论

**格式完全同构，零代码改动。** DSH 技能发现规则（`@deepseek-ai/dsh-skill-filesystem`）与 OKX 官方技能结构逐项对照：

| 维度 | DSH 要求 | OKX 官方 | 结论 |
|---|---|---|---|
| 目录结构 | `<root>/<name>/SKILL.md`（单层，不含嵌套 `**/SKILL.md`） | `skills/okx-cex-market/SKILL.md` | ✅ |
| frontmatter `name` | 必须，kebab-case | `name: okx-cex-market` | ✅ |
| frontmatter `description` | 必须 | 有（长描述，含路由边界） | ✅ |
| 可选字段 | `whenToUse` / `metadata` / `license` 等（open YAML object） | `metadata`（author/version/homepage/agent.requires/agent.install）+ `license: MIT` | ✅（DSH 按 open YAML 解析，多余字段不报错） |
| 资源目录 | `references/`、`scripts/`、`assets/` 按需加载，`{baseDir}` 解析相对路径 | `references/` 5 个命令参考 | ✅ |
| 技能根 | 项目 `.dsh/skills` / 用户 `~/.dsh/skills` / `customSkillDirs` / `~/.agents/skills` | 任意 | ✅ |

## 2. 官方包结构 → 本仓库映射

官方 zip（OKX Skills Marketplace 下载，v1.4.1）内容：

```
okx-cex-market/
├── SKILL.md                # 主技能，12.5 KB
├── _meta.json              # 签名元数据（version 1.4.1，含 6 个文件 sha256）
└── references/
    ├── price-data-commands.md      # ticker/orderbook/candles/trades
    ├── indicator-commands.md       # 70+ 技术指标
    ├── derivatives-commands.md     # funding-rate/mark-price/open-interest 等
    ├── instrument-commands.md      # instruments/instruments-by-category
    └── workflows.md                # 跨技能工作流 + MCP 工具名对照
```

官方 `SKILL.md` 引用了共享文件 `../_shared/preflight.md`（OKX CLI 预检：升级、认证检测、版本漂移检查）。该文件不在 zip 内，本仓库从官方 GitHub 仓库 `skills/_shared/preflight.md` 补齐到 `skills/_shared/preflight.md` —— **安装时必须连同 `_shared/` 一起复制**，否则技能按需加载预检资源会失败。

## 3. 适配改动清单

| 文件 | 改动 | 原因 |
|---|---|---|
| `skills/okx-cex-market/SKILL.md` | 无（原样保留） | 官方 frontmatter 与正文已完全兼容 DSH |
| `skills/okx-cex-market/references/*` | 无（原样保留） | `{baseDir}/references/...` 由 DSH skill 工具按需解析 |
| `skills/okx-cex-market/_meta.json` | 无（原样保留） | 保留官方签名，可做完整性校验 |
| `skills/_shared/preflight.md` | 从官方仓库补齐 | zip 缺失但 SKILL.md 引用 |
| `.dsh-plugin/cordis.patch.yml` | 新增 | 插件通道：注册 `okx-hub` 技能提供者 |
| `package.json` / `.dsh-plugin/package.json` | 新增 | bundle 清单（`dsh.bundle`） |
| `install.ps1` / `install.sh` | 新增 | 一键安装 |

## 4. 完整性校验

官方 `_meta.json` 记录每个文件的 `sha256:<hex>` 签名。本仓库复制后逐文件校验通过：

```
SKILL.md                            sha256:0ac21958…（与官方一致 ✅）
references/derivatives-commands.md  sha256:1a169840…（与官方一致 ✅）
references/indicator-commands.md    sha256:5d0a7ba8…（与官方一致 ✅）
references/instrument-commands.md   sha256:b96511f0…（与官方一致 ✅）
references/price-data-commands.md   sha256:d30d5f40…（与官方一致 ✅）
references/workflows.md             sha256:a6e1b298…（与官方一致 ✅）
```

> 注意：`_meta.json` 中的签名值带 `sha256:` 前缀，比对时需去掉前缀。

## 5. 实测记录（本机 DSH 0.1.0-rc.6）

### 5.1 技能根通道（项目级 `<cwd>/.dsh/skills/`）

1. 将 `skills/okx-cex-market/` 与 `skills/_shared/` 复制到工作区 `.dsh/skills/`
2. DSH watcher 检测到新技能 → 下一次 `agent/pre-step` 把 `okx-cex-market` 发布进模型可见的技能目录（`<available_skills>` 出现该条目）
3. 调用 `skill` 工具（name=`okx-cex-market`）→ 完整返回技能正文 + `Base directory: <技能目录>` + `references/` 相对路径解析 → **加载成功**

### 5.2 插件通道（bundle）

1. `dsh plugin --profile okx-skill-test add <仓库根>` → pnpm 链接成功，profile 初始化
2. `dsh --profile okx-skill-test --dump-config` → 输出含 `# == dsh-okx-skill-hub` 层、`skill-filesystem-okx-hub` 行（providerName `okx-hub`、`includeDefaultRoots: false`、`customSkillDirs` 的 `!!js` 表达式）→ **patch 生效**
3. 对 `!!js` 表达式在真实安装路径（`<profile>/node_modules/dsh-okx-skill-hub/.dsh-plugin/`）求值：`new URL('../skills/', baseUrl)` 正确解析到 bundle 包内 `skills/`，`okx-cex-market/SKILL.md` 存在 → **路径正确**
4. 测试 profile 已删除

### 5.3 关键机制说明

- **baseUrl**：Cordis Loader 为每个 entry 树注入 `baseUrl`（指向组合文件所在目录）。bundle 的 patch 位于 `.dsh-plugin/`，因此 `customSkillDirs` 用 `../skills/` 相对解析到仓库根 `skills/`。
- **为什么 insert 而不是覆盖宿主行**：web 组合中 host 的 `skill-filesystem` 被 `dsh-web-app` 禁用（preset 各自拥有本地发现）。新增独立 provider（`providerName: okx-hub`）注册进 global layer，模型读目录时按 global + scope 链合并。
- **`includeDefaultRoots: false`**：避免重复扫描用户/项目技能根，只暴露本仓库技能，防止目录出现重复条目。

## 6. 收录新技能的流程（写给贡献者）

1. 从 [OKX Skills Marketplace](https://www.okx.com/zh-hans/agent-tradekit/skills/okx-cex-market) 或 [okx/agent-skills](https://github.com/okx/agent-skills) 获取官方技能包（zip 或仓库目录）
2. 按本仓库 `skills/<name>/` 结构放入（保留 `SKILL.md` + `references/` + `_meta.json`）
3. 若技能引用 `_shared/` 资源，确认 `skills/_shared/` 已存在对应文件
4. 用 `_meta.json` 的 sha256 校验复制完整性（注意 `sha256:` 前缀）
5. 在 `README.md` / `README.zh-CN.md` 的技能表登记，并更新本文件
6. 本地按 §5 实测两条通道后提交

## 7. 第二批收录（2026-08-15，来自官方 GitHub 仓库）

从 `okx/agent-skills@github-main` 直接拉取 4 个技能（GitHub 源仓库版本**不带** `_meta.json` 签名，只有市场版 zip 带；收录以仓库结构为准，文件大小与 GitHub tree API 逐一核对通过）：

| 技能 | 文件数 | 依赖 | 凭据要求 | 实测 |
|---|---|---|---|---|
| `okx-cex-portfolio` | 1（仅 SKILL.md） | `okx` CLI | API Key | ✅ 目录发现 |
| `okx-cex-trade` | 9（SKILL.md + 8 references：spot/swap/futures/options/event/templates/workflows） | `okx` CLI | API Key | ✅ 目录发现 |
| `okx-cex-smartmoney` | 5（SKILL.md + 4 references） | `okx` CLI | OAuth | ✅ 目录发现 |
| `okx-sentiment-tracker` | 2（SKILL.md + workflows） | `okx` CLI（`okx news` 模块） | API 凭据（OAuth2.1） | ✅ 目录发现 |

- 4 个技能 frontmatter 均含 `name`（kebab-case）+ `description`，DSH 兼容 ✅
- 3 个引用 `_shared/preflight.md`（仓库已备）；`okx-sentiment-tracker` 无 preflight 引用（自带完整结构）✅
- 全部要求 `@okx_ai/okx-trade-cli`，与已装 CLI（1.4.2）兼容
- 同步至工作区项目技能根后，DSH watcher 立即发现，`<available_skills>` 目录出现全部 5 个技能 ✅
