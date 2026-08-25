$ErrorActionPreference = "Continue"
$REPO = "jiugeyo/star-ksu-build"
$REMOTE = "https://github.com/$REPO.git"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " $REPO  GitHub 鎺ㄩ€佽剼鏈� (PS)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 娓呯悊鏃犲叧鏂囦欢
Remove-Item -Recurse -Force anykernel -ErrorAction SilentlyContinue
Remove-Item -Force *.url -ErrorAction SilentlyContinue

# 2. 鍒濆鍖� / 閰嶇疆
if (-not (Test-Path .git)) { git init -q }
git config user.email "jiugeyo@users.noreply.github.com"
git config user.name  "jiugeyo"

# 3. 鍏宠仈杩滅锛堝凡鍏宠仈鍒欏拷鐣ラ敊璇級
git remote remove origin 2>$null
git remote add origin $REMOTE 2>$null

# 4. 鍏堟媺鍙栬繙绔熀绾垮苟鍚堝苟锛堣В鍐� fetch first / 闈炵┖浠撳簱锛�
Write-Host "鎷夊彇杩滅鍩虹嚎骞跺悎骞�..." -ForegroundColor Yellow
git fetch origin 2>$null
git pull --rebase --no-edit origin main 2>$null

# 5. 鎻愪氦鏈湴鏂囦欢
git add -A 2>$null
$status = git status --porcelain 2>$null
if ($status) {
    git commit -m "init: Xiaomi 11 Ultra SukiSU-Ultra + SUSFS build" 2>$null
    Write-Host "宸插垱寤烘彁浜ゃ€�" -ForegroundColor Green
} else {
    Write-Host "宸ヤ綔鍖烘棤鍙樻洿锛岃烦杩囨彁浜ゃ€�" -ForegroundColor Gray
}

# 6. 鎺ㄩ€侊紙force-with-lease锛氭瘮绾� --force 瀹夊叏锛屼粎褰撹繙绔棤浠栦汉鏂版彁浜ゆ椂鎵嶈鐩栵級
Write-Host "鍗冲皢鎺ㄩ€佸埌 $REMOTE" -ForegroundColor Yellow
Write-Host "鍑瘉锛氱敤鎴峰悕=jiugeyo  瀵嗙爜=浣犵殑 ghp_ 浠ょ墝" -ForegroundColor Yellow
git push --force-with-lease origin HEAD:main
if ($LASTEXITCODE -eq 0) {
    Write-Host "鎺ㄩ€佹垚鍔燂紒璇锋墦寮€ https://github.com/$REPO 鏌ョ湅銆�" -ForegroundColor Green
} else {
    Write-Host "鎺ㄩ€佸け璐ワ紝璇锋鏌ヤ护鐗�/缃戠粶鍚庨噸璇曘€�" -ForegroundColor Red
}
