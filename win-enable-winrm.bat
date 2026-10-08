@echo off

:: Check administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    echo.
    pause
    exit /b 1
)

:: Change the active network to Private
powershell -NoProfile -Command "Get-NetConnectionProfile | Where-Object {$_.IPv4Connectivity -ne 'Disconnected'} | Set-NetConnectionProfile -NetworkCategory Private"

:: Enable WinRM / PowerShell Remoting
powershell -NoProfile -Command "Enable-PSRemoting -Force"

:: Verify WinRM
powershell -NoProfile -Command "Test-WSMan localhost"

pause