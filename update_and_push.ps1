Write-Host "=== 正在提交修復並推送到 GitHub... ===" -ForegroundColor Cyan
git add .
git commit -m "fix: bypass code signing with manual style and archive build"
git push
Write-Host "`n✅ 已成功推送到 GitHub！請前往 GitHub Actions 查看重新編譯進度。" -ForegroundColor Green
