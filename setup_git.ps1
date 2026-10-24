param(
    [Parameter(Mandatory=$false)]
    [string]$RepoUrl
)

Write-Host "=== 星之迴響紫微斗數 App - GitHub 自動編譯 IPA 助手 ===" -ForegroundColor Cyan

if (-not $RepoUrl) {
    $RepoUrl = Read-Host "請輸入您的 GitHub 倉庫 URL (例如 https://github.com/username/ZiweiGhibliApp.git)"
}

if (-not $RepoUrl) {
    Write-Host "未輸入倉庫網址，已取消。" -ForegroundColor Red
    exit
}

Write-Host "正在初始化 Git 倉庫並準備推送..." -ForegroundColor Yellow
git init
git add .
git commit -m "feat: 初版宮崎駿風紫微斗數 App (含 PDF 匯出與 IPA 自動編譯工作流)"
git branch -M main
git remote remove origin 2>$null
git remote add origin $RepoUrl
git push -u origin main

Write-Host "`n✅ 代碼已成功推送至 GitHub！" -ForegroundColor Green
Write-Host "請登入 GitHub 進入該專案的 [Actions] 標籤頁，您將看到雲端 macOS 正自動編譯 ZiweiGhibliApp.ipa。" -ForegroundColor Cyan
Write-Host "編譯完成後，即可在 Artifacts 下載 .ipa 並透過 Sideloadly 免費安裝至 iPhone！" -ForegroundColor Green
