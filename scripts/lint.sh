#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

find "$repo_root" -name '*.json' -not -path '*/.git/*' -print0 |
  while IFS= read -r -d '' file; do
    jq empty "$file"
  done

if command -v shellcheck >/dev/null 2>&1; then
  # Lint maintained shell entrypoints in this baseline repository,
  # including runnable examples. These files are not all installed into apps.
  shellcheck "$repo_root/install.sh" "$repo_root/examples/demo.sh" "$repo_root/scripts/lint.sh" "$repo_root/claude/hooks/validate-command.sh"
else
  printf 'shellcheck not found; skipped shell lint\n'
fi

printf 'lint ok\n'
