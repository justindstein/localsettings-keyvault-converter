#!/usr/bin/env python3

import json
import sys
import os
from collections import defaultdict

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} local.settings.json", file=sys.stderr)
    sys.exit(1)

filepath = sys.argv[1]

if not os.path.isfile(filepath):
    print(f"Error: file not found: {filepath}", file=sys.stderr)
    sys.exit(1)

with open(filepath, "r") as f:
    data = json.load(f)

values = data.get("Values", {})

# Group keys by prefix (anything before the first __)
groups = defaultdict(dict)

for key, value in values.items():
    if "__" in key:
        prefix, _, remainder = key.partition("__")
        groups[prefix][remainder] = value

# Write one .env file per prefix
for prefix, entries in groups.items():
    out_filename = f"{prefix}.env"
    with open(out_filename, "w") as f:
        json.dump(entries, f, indent=4)
    print(f"Written: {out_filename}")
