# localsettings-keyvault-converter

CLI tools to convert between Azure Function `local.settings.json` and modular `.env` files.
Useful when you have multiple option groups (e.g. ION, Hebron) that need to be stored,
shared, or rotated independently — without copying the entire settings file around.

## The Problem

Azure Functions use a flat `local.settings.json` file for local development. When your project
integrates with multiple external services, that file quickly becomes a mix of secrets from
different sources — API credentials, certificates, service bus keys — all in one place.

This makes it hard to:
- Share only the credentials relevant to one service with a colleague
- Rotate secrets for one integration without touching the rest
- Keep a sanitized template in source control alongside real secrets outside of it

## The Solution

Two scripts that act as inverses of each other:

- **`generate_settings.py`** — Takes one or more `.env` files and injects them into a
  `local.settings.json` template, prefixing each key with the filename.
- **`extract_env.py`** — Takes a `local.settings.json` and splits it back out into
  per-prefix `.env` files.

## File Format

Each `.env` file is a flat JSON object named after its option group:
```json
// ION_OPTIONS.env
{
    "BaseUrl": "https://your-ion-api-base-url",
    "OAuthClientId": "YOUR_OAUTH_CLIENT_ID",
    "OAuthClientSecret": "YOUR_OAUTH_CLIENT_SECRET"
}
```

When injected into `local.settings.json`, keys are prefixed with the filename stem:
```json
"ION_OPTIONS__BaseUrl": "https://your-ion-api-base-url",
"ION_OPTIONS__OAuthClientId": "YOUR_OAUTH_CLIENT_ID",
```

This double-underscore convention is the same one the Azure Functions runtime uses to
bind nested configuration objects, so your `IOptions<IonOptions>` bindings will work
without any changes.

## Usage

### Inject `.env` files into `local.settings.json`
```bash
python3 generate_settings.py ION_OPTIONS.env HEBRON_OPTIONS.env > local.settings.json
```

The template at the top of `generate_settings.py` holds all static values
(queue names, service bus connection strings, worker runtime, etc.) — edit it once
and it stays out of your way.

### Extract `.env` files from `local.settings.json`
```bash
python3 extract_env.py local.settings.json
```

This will produce one `.env` file per prefix found in `Values` — e.g.
`ION_OPTIONS.env` and `HEBRON_OPTIONS.env`. Keys without a `__` are ignored.

## Workflow
```
ION_OPTIONS.env   ──┐
                    ├──► generate_settings.py ──► local.settings.json
HEBRON_OPTIONS.env ─┘

local.settings.json ──► extract_env.py ──► ION_OPTIONS.env
                                       └──► HEBRON_OPTIONS.env
```

## Source Control Recommendations

Add to your `.gitignore`:
```
local.settings.json
*.env
```

Commit a sanitized template for reference:
```
local.settings.template.json
```

The sanitized template in this repo uses `OPTIONS_1__` and `OPTIONS_2__` as placeholder
prefixes with all secrets replaced by descriptive strings, so new developers know exactly
what shape of credentials to drop in.

## Requirements

- Python 3.6+
- No external dependencies — uses only the standard library
