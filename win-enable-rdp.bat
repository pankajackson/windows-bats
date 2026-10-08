@echo off
setlocal EnableExtensions
title Enable Remote Desktop

echo.
echo ==============================================
echo          ENABLE REMOTE DESKTOP
echo ==============================================
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Run this script from an Administrator command prompt.
    pause
    exit /b 1
)

:: Windows Home cannot host incoming Microsoft Remote Desktop sessions.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $name=(Get-ComputerInfo -Property WindowsProductName).WindowsProductName; Write-Output $name; if ($name -match 'Home') { exit 2 }"
if errorlevel 1 (
    echo [ERROR] Could not verify the Windows edition, or this edition cannot host RDP.
    echo Check Settings ^> System ^> About ^> Windows specifications.
    pause
    exit /b 1
)

echo [1/3] Enabling Remote Desktop...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul
if errorlevel 1 goto :failed

echo [2/3] Requiring Network Level Authentication...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >nul
if errorlevel 1 goto :failed

echo [3/3] Enabling the built-in Remote Desktop firewall rules...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $rules=Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction Stop; if (-not $rules) { throw 'No Remote Desktop firewall rules were found.' }; $rules | Enable-NetFirewallRule"
if errorlevel 1 goto :failed

echo.
echo [OK] RDP is enabled and NLA is required.
echo Verify access is limited to a trusted network and that the account has a password.
echo Windows firewall rules may still be controlled by Group Policy.
echo.
echo Computer: & hostname
echo IPv4 addresses:
ipconfig | findstr /I "IPv4"
echo.
echo RDP firewall rules:
powershell.exe -NoProfile -Command "Get-NetFirewallRule -DisplayGroup 'Remote Desktop' | Select-Object DisplayName,Enabled,Profile,Direction,Action | Format-Table -AutoSize"
echo.
echo Connect with: mstsc /v:COMPUTER_OR_IP
pause
endlocal
exit /b 0

:failed
echo.
echo [ERROR] A configuration command failed. Review policy or permissions, then verify RDP settings.
pause
endlocal
exit /b 1
