@echo off
setlocal EnableExtensions
title Enable WinRM PowerShell Remoting

echo.
echo ==============================================
echo       ENABLE WINRM / POWERSHELL REMOTING
echo ==============================================
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Run this script from an Administrator command prompt.
    pause
    exit /b 1
)

echo This configures the WinRM HTTP listener on TCP 5985.
echo Connected Public network profiles will be changed to Private so WinRM can add its firewall exception.
echo Use only on a trusted network; the firewall rule will be limited to the local subnet.
echo.

echo Changing connected network profiles to Private...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $profiles=Get-NetConnectionProfile | Where-Object {($_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected') -and $_.NetworkCategory -eq 'Public'}; if ($profiles) { $profiles | Set-NetConnectionProfile -NetworkCategory Private; Write-Output 'Connected Public profiles changed to Private.' } else { Write-Output 'No connected Public profiles needed changing.' }"
if errorlevel 1 (
    echo.
    echo [ERROR] Could not change connected Public network profiles to Private. WinRM setup was not attempted.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Enable-PSRemoting -Force; $rules=Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' -ErrorAction SilentlyContinue; if (-not $rules) { $rules=Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction Stop }; $rules | Where-Object Enabled -eq 'True' | Set-NetFirewallRule -RemoteAddress LocalSubnet; Test-WSMan -ComputerName localhost | Out-Null; Write-Output 'WinRM listener verified locally.'"
if errorlevel 1 (
    echo.
    echo [ERROR] WinRM setup or local verification failed.
    echo On a Public network, Windows may block Enable-PSRemoting. Use a trusted Private or Domain network,
    echo or configure a narrowly scoped firewall rule through your administrator.
    pause
    exit /b 1
)

echo.
echo [OK] WinRM is configured and its enabled inbound rules are scoped to the local subnet.
echo Firewall policy or Group Policy may override local settings.
echo.
echo Computer: & hostname
echo IPv4 addresses:
ipconfig | findstr /I "IPv4"
echo.
echo WinRM listener:
powershell.exe -NoProfile -Command "Get-WSManInstance winrm/config/Listener -Enumerate | Select-Object Address,Transport,Port,Enabled | Format-Table -AutoSize"
echo.
echo Client URL: http://COMPUTER_OR_IP:5985/wsman
echo For non-domain NTLM clients, specify the Windows account and verify the client's TrustedHosts policy.
echo Do not expose TCP 5985 to the public internet.
echo.
pause
endlocal
exit /b 0
