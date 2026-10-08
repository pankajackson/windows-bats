import os
import winrm

host="192.168.1.141"
username="JACKSON"
password="123"
port=5985
protocol="http"
transport="ntlm"

s = winrm.Session(
    f"{protocol}://{host}:{port}/wsman" ,
    auth=(username, password),
    transport=transport,
)

r = s.run_cmd("whoami")
print("Status:", r.status_code)
print("Output:", r.std_out.decode())
