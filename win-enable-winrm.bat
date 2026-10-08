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

echo.
echo ------------------------------------------
echo Listening on TCP 5985:
echo ------------------------------------------
netstat -ano | findstr ":5985"

echo.
echo ------------------------------------------
echo Network Configuration:
echo ------------------------------------------
ipconfig | findstr /I "IPv4"

echo.
echo ------------------------------------------
echo Local WinRM Test:
echo ------------------------------------------
powershell.exe -NoProfile -Command "Test-WSMan localhost"

echo.
echo ==========================================
echo        WinRM CONFIGURATION COMPLETE
echo ==========================================
echo.

echo Computer Name:
hostname

echo.
echo Username:
whoami

echo.
echo Use this from your Linux/Mac client:
echo.
echo   http://YOUR_WINDOWS_IP:5985/wsman
echo.
echo Example:
echo   http://192.168.1.138:5985/wsman
echo.

pause