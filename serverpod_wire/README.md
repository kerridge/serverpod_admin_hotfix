# Serverpod Wire

A CLI tool for generating Serverpod CRUD boilerplate from templates.

## Quick Start

### Usage

Run the scaffold command using `dart run`:

```bash
dart run serverpod_wire/bin/serverpod_wire.dart generate scaffold <ModelName> <field1:type> [field2:type] ...
```

### Example

```bash
dart run serverpod_wire/bin/serverpod_wire.dart generate scaffold Product name:String price:double inStock:bool
```

## Features

- 🚀 Generates server endpoints with full CRUD operations
- 📱 Creates Flutter UI pages (list, form, card widgets)
- 📋 Generates YAML schemas in `.spy` format
- ✨ Automatically runs `serverpod generate` and `serverpod create-migration`
- 📁 Generates files in model-specific folders

## Generated Files

**Server:**
- `lib/src/{model}/{model}.spy` - YAML schema
- `lib/src/{model}/{model}_endpoint.dart` - CRUD endpoint

**Flutter:**
- `lib/pages/{model}/{model}_list.dart` - List page
- `lib/pages/{model}/{model}_form.dart` - Form page
- `lib/widgets/{model}_card.dart` - Card widget

## Supported Field Types

- `String`
- `int`
- `double`
- `bool`
- `DateTime`

Nullable types: Add `?` suffix (e.g., `String?`, `int?`)

## Usage

The CLI works from anywhere in your Serverpod project:
- Project root
- Server directory (ending with `_server`)
- Flutter directory (ending with `_flutter`)

## License

MIT

