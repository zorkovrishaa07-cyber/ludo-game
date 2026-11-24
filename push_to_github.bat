@echo off
title Push Ludo Multi Games to GitHub
color 0B

echo ================================================================
echo    Push Ludo Multi Games to GitHub & Build Cloud APK
echo ================================================================
echo.

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not detected in your PATH.
    echo Please run 'install_tools.bat' first, or install Git from:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b
)

echo Initializing local Git repository...
git init
git add .
git commit -m "Complete Ludo Multi Games bundle with AdMob and CI/CD"
git branch -M main

echo.
echo ================================================================
echo Enter your GitHub repository URL:
echo (Example: https://github.com/YourUsername/ludo-multi-games.git)
echo ================================================================
set /p REPO_URL="Repository URL: "

if "%REPO_URL%"=="" (
    echo [!] No URL entered. Aborting.
    pause
    exit /b
)

echo.
echo Adding remote and pushing to GitHub...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git push -u origin main

echo.
echo ================================================================
echo    Push Successful!
echo ================================================================
echo Now visit your GitHub repository page, click the "Actions" tab,
echo and watch your release APK and AAB build automatically!
echo.
pause
