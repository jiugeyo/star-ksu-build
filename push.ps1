# push.ps1 - 将 star-ksu-build 仓库推送到 GitHub (PowerShell 版)
# 用法：在资源管理器双击运行，或在 PowerShell 中 cd 到本目录后执行 .\push.ps1
#       若被执行策略阻止，先在当前 PowerShell 窗口运行：Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Continue"   # 改为 Continue，避免 git 的 stderr 警告被当作终止异常

$REPO_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $REPO_ROOT

$GITHUB_USER = "jiugeyo"
$REPO_NAME   = "star-ksu-build"
$REMOTE_URL  = "https://github.com/$GITHUB_USER/$REPO_NAME.git"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " star-ksu-build  GitHub 推送脚本 (PS)" -ForegroundColor Cyan
Write-Host " 目标仓库: $GITHUB_USER/$REPO_NAME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 清理无关文件（如误入的 .url 快捷方式等）
Get-ChildItem -Path $REPO_ROOT -Force | Where-Object {
    $_.Name -notin @(".git", ".github", "scripts", "README.md", "push.sh", "push.ps1", ".gitignore") -and
    -not $_.Name.StartsWith("LICENSE")
} | ForEach-Object {
    Write-Host "移除无关文件: $($_.Name)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
}

# 2. 初始化/复用 git 仓库
if (-not (Test-Path (Join-Path $REPO_ROOT ".git"))) {
    Write-Host "初始化 git 仓库..." -ForegroundColor Green
    git init -q
    git branch -M main
}

# 3. 配置本仓库 Git 身份（仅本仓库，不影响全局）
Write-Host "配置本仓库 Git 身份..." -ForegroundColor Green
git config user.email "jiugeyo@users.noreply.github.com"
git config user.name  "jiugeyo"

# 4. 提交
Write-Host "添加文件并提交..." -ForegroundColor Green
git add -A
# 静默检测 HEAD：首次提交前不存在 HEAD 属正常，不输出错误
$lastCommit = git rev-parse HEAD 2>$null
$status = git status --porcelain
if ($status) {
    git commit -m "init: Xiaomi 11 Ultra SukiSU-Ultra + SUSFS build" | Out-Null
    Write-Host "已创建提交。" -ForegroundColor Green
} else {
    Write-Host "工作区无变更，跳过提交。" -ForegroundColor Gray
}

# 5. 设置远端并推送
git remote remove origin 2>$null
git remote add origin $REMOTE_URL

Write-Host ""
Write-Host "即将推送到 $REMOTE_URL" -ForegroundColor Cyan
Write-Host "若提示输入凭证：" -ForegroundColor White
Write-Host "  用户名: $GITHUB_USER" -ForegroundColor White
Write-Host "  密码:  你的 Personal Access Token (ghp_...)" -ForegroundColor White
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "推送成功！" -ForegroundColor Green
    Write-Host "打开 https://github.com/$GITHUB_USER/$REPO_NAME 查看。" -ForegroundColor Green
    Write-Host "然后进入 Actions 标签页，运行工作流即可开始云编译。" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "推送失败。常见原因：" -ForegroundColor Red
    Write-Host "  1) 凭证错误：用户名填 $GITHUB_USER，密码填 ghp_ 开头的令牌。" -ForegroundColor Red
    Write-Host "  2) 仓库已存在且非空：可先到 GitHub 删除该仓库再跑本脚本。" -ForegroundColor Red
    Write-Host "  3) 执行策略阻止：在当前 PowerShell 窗口运行：" -ForegroundColor Red
    Write-Host "     Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
