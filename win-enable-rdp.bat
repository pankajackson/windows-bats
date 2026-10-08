@echo off
setlocal EnableExtensions

title Enable Remote Desktop

echo.
echo ==============================================
echo          ENABLE REMOTE DESKTOP
echo ==============================================
echo.

:: Check Administrator privileges
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo [ERROR] Please run this script as Administrator.
    echo.
    pause
    exit /b 1
)

echo [1/4] Enabling Remote Desktop...

:: Enable RDP connections
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" ^
    /v fDenyTSConnections ^
    /t REG_DWORD ^
    /d 0 ^
    /f >nul

echo [OK] Remote Desktop enabled.
echo.

echo [2/4] Enabling Remote Desktop firewall rules...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue"

echo [OK] Remote Desktop firewall rules enabled.
echo.

echo [3/4] Enabling Network Level Authentication...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" ^
    /v UserAuthentication ^
    /t REG_DWORD ^
    /d 1 ^
    /f >nul

echo [OK] Network Level Authentication enabled.
echo.

echo [4/4] Checking RDP configuration...

echo.
echo ----------------------------------------------
echo RDP Registry:
echo ----------------------------------------------

reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" ^
    /v fDenyTSConnections

echo.
echo ----------------------------------------------
echo RDP Firewall:
echo ----------------------------------------------

powershell.exe -NoProfile -Command ^
    "Get-NetFirewallRule -DisplayGroup 'Remote Desktop' | Select-Object DisplayName, Enabled, Direction, Action"

echo.
echo ----------------------------------------------
echo RDP Port:
echo ----------------------------------------------

netstat -ano | findstr ":3389"

echo.
echo ----------------------------------------------
echo Computer:
echo ----------------------------------------------

hostname

echo.
echo ----------------------------------------------
echo IP Address:
echo ----------------------------------------------

ipconfig | findstr /I "IPv4"

echo.
echo ==============================================
echo       REMOTE DESKTOP ENABLED
echo ==============================================

echo.
echo Connect using:
echo.
echo     mstsc /v:YOUR-IP
echo.
echo Example:
echo.
echo     mstsc /v:192.168.1.138
echo.

pause
endlocal
