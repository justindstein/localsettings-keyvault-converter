#!/usr/bin/env python3

import json
import re
import os
import sys

# ── Template ────────────────────────────────────────────────────────────────
TEMPLATE = """
{
    "IsEncrypted": false,
    "Host": {
        "LocalHttpPort": 8080
    },
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
        "SERVICE_BUS_CONNECTION_STRING__fullyQualifiedNamespace": "",
        "AZURE_TENANT_ID": "",
        "QUEUE_ION_queue_name_1": "",
        "QUEUE_ION_queu_name_2": ""
    },
    "ConnectionStrings": {}
}
"""
# ────────────────────────────────────────────────────────────────────────────

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} FILE1.env FILE2.env ...", file=sys.stderr)
    sys.exit(1)

result = json.loads(TEMPLATE)

for filepath in sys.argv[1:]:
    if not os.path.isfile(filepath):
        print(f"Warning: file not found: {filepath}", file=sys.stderr)
        continue

    prefix = os.path.splitext(os.path.basename(filepath))[0]

    with open(filepath, "r") as f:
        content = f.read().strip()

    match = re.search(r'\{.*\}', content, re.DOTALL)
    if not match:
        print(f"Warning: no JSON found in {filepath}", file=sys.stderr)
        continue

    data = json.loads(match.group())

    for key, value in data.items():
        result["Values"][f"{prefix}__{key}"] = value

print(json.dumps(result, indent=4))
