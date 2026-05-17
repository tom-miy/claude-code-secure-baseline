#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --target /path/to/your-app [--force]

Installs only the Claude Code hardening files:
  CLAUDE.md
  .claude/settings.json
  .claude/hooks/validate-command.sh
  .claude/skills/db-change-review/skill.md

Existing files are not overwritten unless --force is provided.
USAGE
}

target=""
force="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      if [ "$#" -lt 2 ]; then
        printf 'error: --target requires a path\n' >&2
        exit 1
      fi
      target=$2
      shift 2
      ;;
    --force)
      force="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$target" ]; then
  printf 'error: --target is required\n' >&2
  usage >&2
  exit 1
fi

repo_root=$(unset CDPATH; cd -- "$(dirname -- "$0")" && pwd)
target_dir=$(unset CDPATH; cd -- "$target" && pwd)

install_file() {
  source_file=$1
  destination_file=$2

  if [ -e "$destination_file" ] && [ "$force" != "true" ]; then
    printf 'skip: %s already exists (use --force to overwrite)\n' "$destination_file"
    return 0
  fi

  mkdir -p "$(dirname -- "$destination_file")"
  cp "$source_file" "$destination_file"
  printf 'installed: %s\n' "$destination_file"
}

install_file "$repo_root/claude/CLAUDE.example.md" "$target_dir/CLAUDE.md"
install_file "$repo_root/claude/settings.example.json" "$target_dir/.claude/settings.json"

hook_destination="$target_dir/.claude/hooks/validate-command.sh"
should_chmod_hook="false"
if [ ! -e "$hook_destination" ] || [ "$force" = "true" ]; then
  should_chmod_hook="true"
fi

install_file "$repo_root/claude/hooks/validate-command.sh" "$hook_destination"
if [ "$should_chmod_hook" = "true" ]; then
  chmod +x "$hook_destination"
fi

install_file "$repo_root/claude/skills/db-change-review/skill.md" "$target_dir/.claude/skills/db-change-review/skill.md"

printf '\nDone. Review CLAUDE.md and .claude/settings.json with Claude Code /status, /permissions, and /memory before production use.\n'
