$ErrorActionPreference = "Continue"
$REPO = "jiugeyo/star-ksu-build"
$REMOTE = "https://github.com/$REPO.git"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " $REPO  GitHub 推送脚本 (PS)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 清理无关文件
Remove-Item -Recurse -Force anykernel -ErrorAction SilentlyContinue
Remove-Item -Force *.url -ErrorAction SilentlyContinue

# 2. 初始化 / 配置
if (-not (Test-Path .git)) { git init -q }
git config user.email "jiugeyo@users.noreply.github.com"
git config user.name  "jiugeyo"

# 3. 关联远端（已关联则忽略错误）
git remote remove origin 2>$null
git remote add origin $REMOTE 2>$null

# 4. 先拉取远端基线并合并（解决 fetch first / 非空仓库）
Write-Host "拉取远端基线并合并..." -ForegroundColor Yellow
git fetch origin 2>$null
git pull --rebase --no-edit origin main 2>$null

# 5. 提交本地文件
git add -A 2>$null
$status = git status --porcelain 2>$null
if ($status) {
    git commit -m "init: Xiaomi 11 Ultra SukiSU-Ultra + SUSFS build" 2>$null
    Write-Host "已创建提交。" -ForegroundColor Green
} else {
    Write-Host "工作区无变更，跳过提交。" -ForegroundColor Gray
}

# 6. 推送（force-with-lease：比纯 --force 安全，仅当远端无他人新提交时才覆盖）
Write-Host "即将推送到 $REMOTE" -ForegroundColor Yellow
Write-Host "凭证：用户名=jiugeyo  密码=你的 ghp_ 令牌" -ForegroundColor Yellow
git push --force-with-lease origin HEAD:main
if ($LASTEXITCODE -eq 0) {
    Write-Host "推送成功！请打开 https://github.com/$REPO 查看。" -ForegroundColor Green
} else {
    Write-Host "推送失败，请检查令牌/网络后重试。" -ForegroundColor Red
}
