#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 -m json.tool "$ROOT_DIR/.codex-plugin/plugin.json" >/dev/null
python3 -m json.tool "$ROOT_DIR/.claude-plugin/plugin.json" >/dev/null
python3 -m json.tool "$ROOT_DIR/.claude-plugin/marketplace.json" >/dev/null
python3 -m json.tool "$ROOT_DIR/marketplace.json" >/dev/null

test -f "$ROOT_DIR/.claude-plugin/plugin.json"
test -f "$ROOT_DIR/.claude-plugin/marketplace.json"
test -f "$ROOT_DIR/skills/spec-writer/SKILL.md"
test -f "$ROOT_DIR/skills/spec-writer/agents/openai.yaml"
test -f "$ROOT_DIR/skills/spec-writer/examples/since-flag.md"
test -f "$ROOT_DIR/skills/spec-writer/examples/search-endpoint.md"

grep -q '^name: spec-writer$' "$ROOT_DIR/skills/spec-writer/SKILL.md"
grep -q '^description:' "$ROOT_DIR/skills/spec-writer/SKILL.md"

sh -n "$ROOT_DIR/scripts/install.sh"

echo "skills repo validation passed"
