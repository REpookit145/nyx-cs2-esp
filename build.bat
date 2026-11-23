@echo off
setlocal
cd /d "%~dp0"

rem ---------------------------------------------------------------
rem Locate CMake: PATH first, otherwise the copy bundled with VS.
rem ---------------------------------------------------------------
set "CMAKE="
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSPATH="

where cmake >nul 2>nul && set "CMAKE=cmake"

if not defined CMAKE if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSPATH=%%i"
)

if not defined CMAKE if defined VSPATH if exist "%VSPATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" (
    set "CMAKE=%VSPATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
)

if not defined CMAKE (
    echo [!] cmake not found. Install Visual Studio with "Desktop development with C++".
    exit /b 1
)

echo [*] using cmake: %CMAKE%

rem ---------------------------------------------------------------
rem ImGui dependency
rem ---------------------------------------------------------------
if not exist "third_party\imgui\imgui.cpp" (
    echo [*] fetching imgui...
    if not exist "third_party" mkdir third_party
    git clone --depth 1 --branch v1.91.5 https://github.com/ocornut/imgui third_party\imgui
    if errorlevel 1 (
        echo [!] git clone failed. Install git or drop imgui into third_party\imgui
        exit /b 1
    )
)

rem ---------------------------------------------------------------
rem Configure + build
rem ---------------------------------------------------------------
echo [*] configuring...
"%CMAKE%" -B build -A x64
if errorlevel 1 exit /b 1

echo [*] building...
"%CMAKE%" --build build --config Release
if errorlevel 1 exit /b 1

echo.
echo [+] done:  build\Release\cs2_esp.dll  and  build\Release\injector.exe
echo [+] put offsets.ini next to cs2_esp.dll before injecting.
endlocal
