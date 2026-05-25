#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SKILL_NAME=spec-writer
SKILL_SOURCE="$ROOT_DIR/skills/$SKILL_NAME"

usage() {
  cat <<'USAGE'
Usage:
  scripts/install.sh codex
  scripts/install.sh claude
  scripts/install.sh generic /path/to/skills-root
  scripts/install.sh all

Targets:
  codex    Install into ${CODEX_HOME:-$HOME/.codex}/skills
  claude   Install into $HOME/.claude/skills
  generic  Install into a provided Agent Skills root
  all      Install into Codex and Claude Code roots
USAGE
}

install_skill() {
  dest_root=$1
  dest_dir="$dest_root/$SKILL_NAME"

  if [ ! -d "$SKILL_SOURCE" ]; then
    echo "Missing skill source: $SKILL_SOURCE" >&2
    exit 1
  fi

  mkdir -p "$dest_root"
  rm -rf "$dest_dir"
  cp -R "$SKILL_SOURCE" "$dest_dir"
  echo "Installed $SKILL_NAME to $dest_dir"
}

target=${1:-}

case "$target" in
  codex)
    install_skill "${CODEX_HOME:-$HOME/.codex}/skills"
    ;;
  claude|claude-code)
    install_skill "$HOME/.claude/skills"
    ;;
  generic)
    dest=${2:-}
    if [ -z "$dest" ]; then
      echo "Missing skills root for generic install." >&2
      usage
      exit 2
    fi
    install_skill "$dest"
    ;;
  all)
    install_skill "${CODEX_HOME:-$HOME/.codex}/skills"
    install_skill "$HOME/.claude/skills"
    ;;
  *)
    usage
    exit 2
    ;;
esac
