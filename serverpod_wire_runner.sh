#!/bin/bash
# Runner script for serverpod_wire that uses dart run for reliable execution

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
dart run serverpod_wire/bin/serverpod_wire.dart "$@"

