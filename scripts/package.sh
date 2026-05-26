#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR=${1:-"$ROOT_DIR/dist"}
OUT_PATH="$OUT_DIR/spec-writer.zip"

mkdir -p "$OUT_DIR"

git -C "$ROOT_DIR" archive \
  --format=zip \
  --prefix=spec-writer/ \
  --output="$OUT_PATH" \
  HEAD:skills/spec-writer

if command -v unzip >/dev/null 2>&1; then
  unzip -tq "$OUT_PATH" >/dev/null
  unzip -l "$OUT_PATH" | grep -q 'spec-writer/SKILL.md'
fi

echo "wrote $OUT_PATH"
