# Windows remote access helpers

Small scripts to enable Microsoft Remote Desktop (RDP) or WinRM PowerShell remoting on Windows 10/11.
Run the relevant `.bat` file from an **Administrator** Command Prompt on the Windows machine.

## Remote Desktop

`win-enable-rdp.bat` enables RDP, requires Network Level Authentication (NLA), and enables Windows' built-in Remote Desktop firewall rules. Windows Home editions cannot host incoming Microsoft RDP sessions. Use a strong password on every account allowed to sign in, and grant access only to the users who need it.

## WinRM

`win-enable-winrm.bat` changes connected **Public** profiles to **Private**, then runs `Enable-PSRemoting`, checks the local listener, and scopes enabled WinRM HTTP inbound firewall rules to the local subnet. Run it only when those connected Public networks are trusted; a laptop connected to public Wi-Fi should not use this profile change. Existing Private and Domain profiles are left as they are. Avoid exposing TCP 5985 to the internet.

The default listener uses HTTP on TCP 5985. For workgroup or non-domain clients, this repository's client uses NTLM; use a strong Windows account password and configure the client's TrustedHosts narrowly if required. For broader or untrusted networks, use a managed HTTPS listener and appropriate certificate/authentication policy instead of opening HTTP broadly.

## Test from Linux/macOS

Install the client dependency:

```sh
python -m pip install pywinrm
```

Run the connectivity check; it prompts for the password rather than storing it in the file:

```sh
python test-winrm.py 192.168.1.141 --username 'COMPUTERNAME\username'
```

You can omit `--username` to be prompted for it. The test runs `whoami`; a successful local `Test-WSMan` on Windows alone does not prove a remote client can connect.

## Notes

- Local firewall policy or domain Group Policy can override these settings.
- Enabling either service increases remote access to the machine. Use only when needed and review firewall scope and allowed accounts.
