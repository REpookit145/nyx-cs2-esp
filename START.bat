@echo off
setlocal
cd /d "%~dp0build\Release"
title CS2 ESP launcher

if not exist "cs2_esp.dll" (
    echo [!] cs2_esp.dll missing. Build first with build.bat.
    pause
    exit /b 1
)

tasklist /fi "imagename eq cs2.exe" | find /i "cs2.exe" >nul
if errorlevel 1 (
    echo [!] CS2 is not running.
    echo     Start the game and join a match, THEN run this again.
    pause
    exit /b 1
)

echo [*] injecting into cs2.exe ...
injector.exe cs2.exe "%~dp0build\Release\cs2_esp.dll"
echo.
echo [*] done. Alt-tab to CS2 and press INSERT.
pause
endlocal
