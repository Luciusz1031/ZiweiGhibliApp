@echo off
chcp 65001 >nul
echo ========================================================
echo   🦌 小鹿兒紫微斗數 - Firebase Hosting 一鍵佈署工具
echo   目標專案 Project ID: xiaoluerziwei
echo ========================================================
echo.
echo 步驟 1/2: 正在確認 Firebase 登入... (若尚未登入會開啟瀏覽器請點選允許)
call npx -y firebase-tools@latest login
echo.
echo 步驟 2/2: 正在將 public 網頁發布至 Firebase Hosting...
call npx -y firebase-tools@latest deploy --only hosting
echo.
echo ========================================================
echo   🎉 佈署成功！
echo   您的線上網址：
echo   👉 https://xiaoluerziwei.web.app
echo   👉 https://xiaoluerziwei.firebaseapp.com
echo ========================================================
pause
