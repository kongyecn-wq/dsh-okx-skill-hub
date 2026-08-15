#!/usr/bin/env bash
# dsh-okx-skill-hub — DeepSeek Harness (DSH) 一键安装脚本 (macOS / Linux)
#
# 用法:
#   ./install.sh                     # 默认安装到 $DSH_HOME/skills（用户级）
#   ./install.sh --project           # 安装到当前项目 <cwd>/.dsh/skills
#   ./install.sh --bundle            # 以 bundle 插件方式安装（推荐，可随 dsh plugin 卸载）
#
# 安装来源优先级（按顺序尝试）:
#   1. 环境变量 DSH_OKX_SKILLS 指向的技能目录
#   2. 脚本同目录下的 skills/

set -euo pipefail

PROJECT=0
BUNDLE=0
PROFILE="web"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT=1; shift ;;
    --bundle) BUNDLE=1; shift ;;
    --profile) PROFILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${DSH_OKX_SKILLS:-$SCRIPT_DIR/skills}"

if [[ ! -f "$SOURCE/okx-cex-market/SKILL.md" ]]; then
  echo "错误: 找不到技能目录 $SOURCE（期望其中有 okx-cex-market/SKILL.md）。可设置 DSH_OKX_SKILLS 指定。" >&2
  exit 1
fi

if [[ "$BUNDLE" -eq 1 ]]; then
  if ! command -v dsh >/dev/null 2>&1; then
    echo "错误: 未找到 dsh CLI。请先安装 DeepSeek Harness，或去掉 --bundle 改用目录复制安装。" >&2
    exit 1
  fi
  REPO_DIR="$SCRIPT_DIR"   # 脚本位于仓库根，直接作为 bundle 目录
  echo "[1/2] dsh plugin --profile $PROFILE add $REPO_DIR"
  dsh plugin --profile "$PROFILE" add "$REPO_DIR"
  echo "[2/2] 验证配置层"
  dsh --profile "$PROFILE" --dump-config | grep -q "skill-filesystem-okx-hub" || true
  echo "✅ bundle 已安装。技能 okx-cex-market 将通过插件自带的 skills/ 目录注册。"
  echo "   卸载: dsh plugin --profile $PROFILE remove dsh-okx-skill-hub"
  exit 0
fi

if [[ "$PROJECT" -eq 1 ]]; then
  DEST="$(pwd)/.dsh/skills"
else
  DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
  DEST="$DSH_HOME/skills"
fi

echo "[1/2] 复制技能 -> $DEST"
mkdir -p "$DEST"
cp -R "$SOURCE"/* "$DEST"/

echo "[2/2] 校验"
if [[ -f "$DEST/okx-cex-market/SKILL.md" ]]; then
  echo "✅ 安装完成: $DEST/okx-cex-market/SKILL.md"
  echo "   重启/刷新 DSH 会话后，模型即可通过 skill 目录发现 okx-cex-market。"
  echo "   卸载: rm -rf \"$DEST/okx-cex-market\""
else
  echo "错误: 复制后校验失败" >&2
  exit 1
fi
