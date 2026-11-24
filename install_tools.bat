@echo off
title 1-Click Install Developer Tools (Git, Java 17, Flutter)
color 0A

echo ================================================================
echo    Ludo Multi Games - 1-Click Windows Developer Setup
echo ================================================================
echo.
echo This script will install:
echo   1. Git for Windows
echo   2. Eclipse Adoptium Temurin OpenJDK 17
echo   3. Flutter SDK (Stable Channel)
echo.
echo NOTE: A Windows administrator UAC prompt will appear.
echo       Please click "YES" to allow the installations.
echo.
pause

echo.
echo [1/3] Installing Git for Windows...
winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo [!] Note: If Git was already installed or prompted, continuing to next step...
)

echo.
echo [2/3] Installing Eclipse Adoptium Temurin JDK 17...
winget install --id EclipseAdoptium.Temurin.17.JDK -e --source winget --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo [!] Note: Continuing to next step...
)

echo.
echo [3/3] Installing Flutter SDK...
winget install --id Flutter.Flutter -e --source winget --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo [!] Note: Continuing...
)

echo.
echo ================================================================
echo    Installation Process Complete!
echo ================================================================
echo.
echo Please CLOSE and RE-OPEN your terminal/command prompt so that
echo the new PATH environment variables take effect.
echo.
echo After restarting your terminal, you can run:
echo    flutter doctor
echo    flutter build apk --release
echo.
pause
