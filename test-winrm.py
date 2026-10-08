#!/usr/bin/env python3
"""Run a small WinRM connectivity check against a Windows host."""

import argparse
import getpass
import sys

try:
    import winrm
except ImportError:
    sys.exit("Missing dependency. Install it with: python -m pip install pywinrm")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("host", help="Windows hostname or IP address")
    parser.add_argument("--username", help=r"Windows account, e.g. COMPUTER\user or DOMAIN\user")
    parser.add_argument("--port", type=int, default=5985)
    args = parser.parse_args()

    username = args.username or input("Windows username: ").strip()
    if not username:
        parser.error("username cannot be empty")
    password = getpass.getpass("Windows password: ")

    endpoint = f"http://{args.host}:{args.port}/wsman"
    try:
        session = winrm.Session(
            endpoint,
            auth=(username, password),
            transport="ntlm",
            read_timeout_sec=30,
            operation_timeout_sec=20,
        )
        result = session.run_cmd("whoami")
    except Exception as exc:  # pywinrm surfaces transport and authentication errors here
        print(f"WinRM request failed: {exc}", file=sys.stderr)
        return 1

    print(f"HTTP status: {result.status_code}")
    stdout = result.std_out.decode(errors="replace").strip()
    stderr = result.std_err.decode(errors="replace").strip()
    if stdout:
        print(f"Output: {stdout}")
    if stderr:
        print(f"Error: {stderr}", file=sys.stderr)
    return 0 if result.status_code == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
