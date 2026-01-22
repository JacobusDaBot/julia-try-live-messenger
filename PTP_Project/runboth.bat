@echo off
REM Change to the directory where this batch file is located
cd /d "%~dp0"
echo Running from: %CD%
echo.

echo Starting BetterServer...
start wt -d "%CD%" julia scripts\\betterserver.jl
timeout /t 2 >nul
echo Starting BetterUser...
start wt -d "%CD%" julia scripts\\betteruser.jl

echo.
echo Both terminals started!
echo Press any key to close them...
pause >nul

taskkill /f /im WindowsTerminal.exe >nul 2>&1
taskkill /f /im wt.exe >nul 2>&1