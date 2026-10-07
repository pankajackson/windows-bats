@echo off
setlocal

title Enable WinRM - Windows 10

echo.
echo ==========================================
echo       Windows WinRM Configuration
echo ==========================================
echo.

:: Check administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    echo.
    pause
    exit /b 1
)

echo [1/9] Starting WinRM service...
sc config WinRM start= auto >nul
net start WinRM >nul 2>&1

echo [2/9] Configuring WinRM...
winrm quickconfig -q

echo [3/9] Enabling Negotiate/NTLM authentication...
winrm set winrm/config/service/auth "@{Negotiate=""true""}"

echo [4/9] Ensuring HTTP listener on port 5985...

winrm enumerate winrm/config/listener | findstr /I "Transport = HTTP" >nul

if %errorlevel% neq 0 (
    echo Creating HTTP listener...
    winrm create winrm/config/Listener?Address=*+Transport=HTTP
) else (
    echo HTTP listener already exists.
)

echo [5/9] Enabling WinRM firewall rule...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'" 2>nul

echo [6/9] Enabling PowerShell Remoting...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

echo [7/9] Configuring LocalAccountTokenFilterPolicy...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
    /v LocalAccountTokenFilterPolicy ^
    /t REG_DWORD ^
    /d 1 ^
    /f >nul

echo [8/9] Restarting WinRM service...
net stop WinRM >nul 2>&1
net start WinRM >nul 2>&1

echo [9/9] Checking configuration...
echo.
echo ------------------------------------------
echo WinRM Service:
echo ------------------------------------------
sc query WinRM | findstr /I "STATE"

echo.
echo ------------------------------------------
echo WinRM Listener:
echo ------------------------------------------
winrm enumerate winrm/config/listener

echo.
echo ------------------------------------------
echo WinRM Authentication:
echo ------------------------------------------
winrm get winrm/config/service/auth

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
endlocal
