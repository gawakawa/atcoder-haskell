#!/usr/bin/env bash

set -euo pipefail

ACC_CONFIG_DIR=$(acc config-dir)

[ -e "$ACC_CONFIG_DIR" ] && rm -rf "$ACC_CONFIG_DIR"
ln -s "$ROOT/acc-config" "$ACC_CONFIG_DIR"
acc config oj-path "$(which oj)"
