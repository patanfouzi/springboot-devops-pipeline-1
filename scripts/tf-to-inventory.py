#!/usr/bin/env python3
import json, sys
if len(sys.argv) < 2:
    print("Usage: tf-to-inventory.py path/to/tfoutput.json")
    sys.exit(1)

obj = json.load(open(sys.argv[1]))

# Example outputs in Terraform: app_public_ip, mysql_public_ip
app_ip = obj.get('app_public_ip', {}).get('value')
mysql_ip = obj.get('mysql_public_ip', {}).get('value')

if app_ip:
    print("[app]")
    print(f"{app_ip} ansible_user=ubuntu")
    print()

if mysql_ip:
    print("[mysql]")
    print(f"{mysql_ip} ansible_user=ubuntu")
    print()
