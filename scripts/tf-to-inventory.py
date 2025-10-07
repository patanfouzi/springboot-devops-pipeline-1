#!/usr/bin/env python3
import json, sys

if len(sys.argv) < 2:
    print("Usage: tf-to-inventory.py path/to/tfoutput.json")
    sys.exit(1)

tf = json.load(open(sys.argv[1]))

print("[app]")
if 'app_public_ip' in tf:
    for ip in tf['app_public_ip']['value']:
        print(f"{ip} ansible_user=ubuntu")
else:
    # fallback: first output
    first = next(iter(tf.values()))
    ip = first.get('value')
    print(f"{ip} ansible_user=ubuntu")

print("\n[mysql]")
if 'mysql_public_ip' in tf:
    for ip in tf['mysql_public_ip']['value']:
        print(f"{ip} ansible_user=ubuntu")
