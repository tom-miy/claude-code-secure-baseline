#!/usr/bin/env bash
set -euo pipefail

repo_root=$(unset CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
hook="$repo_root/claude/hooks/validate-command.sh"

color_enabled="false"
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  color_enabled="true"
fi

color() {
  color_code=$1
  text=$2

  if [ "$color_enabled" = "true" ]; then
    printf '\033[%sm%s\033[0m' "$color_code" "$text"
  else
    printf '%s' "$text"
  fi
}

run_case() {
  label=$1
  input_file=$2
  expected=$3

  printf '\n== %s ==\n' "$(color '1;36' "$label")"
  set +e
  "$hook" < "$input_file"
  status=$?
  set -e

  if [ "$status" -eq 2 ]; then
    status_text=$(color '33' "$status")
  elif [ "$status" -eq 0 ]; then
    status_text=$(color '32' "$status")
  else
    status_text=$(color '31' "$status")
  fi

  printf 'exit code: %s\n' "$status_text"
  if [ "$status" -eq "$expected" ]; then
    printf 'result: %s\n' "$(color '32' 'ok')"
  else
    printf 'result: %s expected exit code %s\n' "$(color '31' 'failed:')" "$expected" >&2
    return 1
  fi
}

run_case "unsafe rm -rf" "$repo_root/examples/unsafe-rm-tool-input.json" 2
run_case "unsafe curl pipe" "$repo_root/examples/unsafe-tool-input.json" 2
run_case "unsafe database command" "$repo_root/examples/unsafe-db-tool-input.json" 2
run_case "safe git status" "$repo_root/examples/safe-tool-input.json" 0

printf '\n%s\n' "$(color '1;32' 'Demo complete.')"
