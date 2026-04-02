# localsettings-keyvault-converter

CLI scripts to convert between Azure Function `local.settings.json` and modular `.env`
files — useful when multiple external services each have their own credentials that need
to be managed, shared, or rotated independently.

## Scripts

- **`tolocalsettings.sh`** — Takes one or more `.env` files and injects them into a
  `local.settings.json` template, prefixing each key with the filename stem.
- **`tokeyvaultsecrets.sh`** — Takes a `local.settings.json` and splits it back out into
  per-prefix `.env` files based on the `__` separator.

## Usage

### `.env` → `local.settings.json`
```bash
./tolocalsettings.sh OPTIONS_1.env.test OPTIONS_2.env.test > local.settings.json
```

### `local.settings.json` → `.env` files
```bash
./tokeyvaultsecrets.sh local.settings.json
# outputs: OPTIONS_1.env, OPTIONS_@.env
```

## Key Convention

The double-underscore prefix convention mirrors how the Azure Functions runtime binds
nested configuration objects, so `IOptions<T>` bindings work without any changes.
```
OPTIONS_1.env { "BaseUrl": "..." }  →  "OPTIONS_1__BaseUrl": "..."
```

## Requirements

- Python 3.6+
- No external dependencies
