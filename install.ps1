# dsh-okx-skill-hub — DeepSeek Harness (DSH) 一键安装脚本 (Windows / PowerShell)
#
# 用法:
#   powershell -ExecutionPolicy Bypass -File install.ps1            # 默认安装到 $DSH_HOME\skills（用户级）
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Project   # 安装到当前项目 <cwd>\.dsh\skills
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Bundle    # 以 bundle 插件方式安装（推荐，可随 dsh plugin 卸载）
#
# 安装来源优先级（按顺序尝试）:
#   1. 环境变量 $env:DSH_OKX_SKILLS 指向的技能目录
#   2. 脚本同目录下的 skills\

param(
    [switch]$Project,   # 安装到项目级 <cwd>\.dsh\skills
    [switch]$Bundle,    # 用 dsh plugin add 以 bundle 方式安装（需要 dsh CLI）
    [string]$Profile = "web"  # bundle 安装目标 profile
)

$ErrorActionPreference = "Stop"

# --- 定位技能源目录 ---------------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = $env:DSH_OKX_SKILLS
if (-not $source) { $source = Join-Path $scriptDir "skills" }
if (-not (Test-Path (Join-Path $source "okx-cex-market\SKILL.md"))) {
    Write-Error "找不到技能目录: $source （期望其中有 okx-cex-market\SKILL.md）。可设置 `$env:DSH_OKX_SKILLS 指定。"
    exit 1
}

if ($Bundle) {
    # --- bundle 方式: dsh plugin add 本仓库 ----------------------------------
    if (-not (Get-Command dsh -ErrorAction SilentlyContinue)) {
        Write-Error "未找到 dsh CLI。请先安装 DeepSeek Harness，或去掉 -Bundle 改用目录复制安装。"
        exit 1
    }
    $repoDir = $scriptDir   # 脚本位于仓库根，直接作为 bundle 目录
    Write-Host "[1/2] dsh plugin --profile $Profile add $repoDir"
    dsh plugin --profile $Profile add $repoDir
    if ($LASTEXITCODE -ne 0) { Write-Error "dsh plugin add 失败 (exit $LASTEXITCODE)"; exit $LASTEXITCODE }
    Write-Host "[2/2] 验证配置层（如已启动 DSH，请刷新会话使技能目录生效）"
    dsh --profile $Profile --dump-config | Select-String -Pattern "skill-filesystem-okx-hub" -Quiet | Out-Null
    Write-Host "✅ bundle 已安装。技能 okx-cex-market 将通过插件自带的 skills/ 目录注册。"
    Write-Host "   卸载: dsh plugin --profile $Profile remove dsh-okx-skill-hub"
    exit 0
}

# --- 目录复制方式 -------------------------------------------------------------
if ($Project) {
    $root = Get-Location
    $dest = Join-Path $root ".dsh\skills"
} else {
    $dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $HOME ".dsh" }
    $dest = Join-Path $dshHome "skills"
}

Write-Host "[1/2] 复制技能 -> $dest"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Path (Join-Path $source "*") -Destination $dest -Recurse -Force
Write-Host "[2/2] 校验"
$check = Join-Path $dest "okx-cex-market\SKILL.md"
if (Test-Path $check) {
    Write-Host "✅ 安装完成: $check"
    Write-Host "   重启/刷新 DSH 会话后，模型即可通过 skill 目录发现 okx-cex-market。"
    Write-Host "   卸载: Remove-Item -Recurse -Force (Join-Path '$dest' 'okx-cex-market')"
} else {
    Write-Error "复制后校验失败: 未找到 $check"
    exit 1
}
