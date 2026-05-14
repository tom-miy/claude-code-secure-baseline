#!/usr/bin/env bash
set -euo pipefail

input_json=$(cat)

if ! command_text=$(printf '%s' "$input_json" | jq -r '.tool_input.command // ""' 2>/dev/null); then
  printf 'Claude Code hardening baseline blocked command: invalid hook input or missing jq-readable JSON.\n' >&2
  exit 2
fi

if [ -z "$command_text" ]; then
  exit 0
fi

lower_command=$(printf '%s' "$command_text" | tr '[:upper:]' '[:lower:]')

block() {
  reason=$1
  printf 'Claude Code hardening baseline blocked command: %s\n' "$reason" >&2
  printf 'Command: %s\n' "$command_text" >&2
  exit 2
}

matches() {
  pattern=$1
  printf '%s' "$lower_command" | grep -Eq "$pattern"
}

if matches '(^|[;&|[:space:]])rm[[:space:]]+(-[^[:space:]]*r[^[:space:]]*f|-rf|-fr)([[:space:]]|$)'; then
  block 'recursive forced removal is denied'
fi

if matches '(^|[;&|[:space:]])rm([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(-r|-R|--recursive)([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(-f|--force)([[:space:]]|$)'; then
  block 'recursive forced removal is denied'
fi

if matches '(^|[;&|[:space:]])rm([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(-f|--force)([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(-r|-R|--recursive)([[:space:]]|$)'; then
  block 'recursive forced removal is denied'
fi

if matches '(^|[;&|[:space:]])(curl|wget)([[:space:]][^|;&]*)?\|[[:space:]]*(sh|bash|zsh|dash)([[:space:]]|$)'; then
  block 'download-and-execute pipeline is denied'
fi

if matches '(^|[;&|[:space:]])(curl|wget)([[:space:]][^|;&]*)?\|[[:space:]]*((env|sudo)[[:space:]]+)?(/bin/|/usr/bin/)?(sh|bash|zsh|dash)([[:space:]]|$)'; then
  block 'download-and-execute pipeline is denied'
fi

git_prefix='(^|[;&|[:space:]])git([[:space:]]+(-c[[:space:]]+[^;&|[:space:]]+|-C[[:space:]]+[^;&|[:space:]]+|--git-dir[=[:space:]][^;&|[:space:]]+|--work-tree[=[:space:]][^;&|[:space:]]+))*[[:space:]]+push'

if matches "${git_prefix}([^;&|]*[[:space:]])--force(-with-lease)?([[:space:]]|$)"; then
  block 'forced git push is denied'
fi

if matches "${git_prefix}([^;&|]*[[:space:]])--force(-with-lease)?="; then
  block 'forced git push is denied'
fi

if matches "${git_prefix}([^;&|]*[[:space:]])-f([[:space:]]|$)"; then
  block 'forced git push is denied'
fi

if matches '(^|[;&|[:space:]])chmod[[:space:]]+([^;&|[:space:]]+[[:space:]]+)*0?777([[:space:]]|$)'; then
  block 'world-writable chmod 777 is denied'
fi

if matches '(^|[;&|[:space:]])chmod[[:space:]]+([^;&|[:space:]]+[[:space:]]+)*[ugo]*[ao][ugo]*[+=][rwx]*w[rwx]*([[:space:]]|$)'; then
  block 'broad write chmod mode is denied'
fi

if matches '(^|[;&|[:space:]])chmod[[:space:]]+([^;&|[:space:]]+[[:space:]]+)*\+[rwx]*w[rwx]*([[:space:]]|$)'; then
  block 'broad write chmod mode is denied'
fi

file_access_command='(cat|less|more|tail|head|sed|awk|grep|rg|find|ls|stat|wc|cp|mv|tar|zip|unzip|open|code|vim|vi|nano|emacs)'
path_prefix='['\''"]?([^;&|[:space:]'\''"]*/)?'
path_suffix='['\''"]?([;&|>[:space:]]|$)'

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+${path_prefix}\\.env(\\.[^;&|[:space:]'\''\"]*)?${path_suffix}"; then
  block 'secret-like .env file access is denied'
fi

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+${path_prefix}secrets(/|${path_suffix})"; then
  block 'secret directory access is denied'
fi

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+${path_prefix}config/credentials\\.json${path_suffix}"; then
  block 'credential file access is denied'
fi

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+['\''\"]?[^;&|[:space:]'\''\"]+\\.(pem|key)['\''\"]?([;&|>[:space:]]|$)"; then
  block 'private key file access is denied'
fi

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+['\''\"]?(~[^/[:space:]'\''\"]*/|\\\$home/|/users/[^/[:space:]'\''\"]+/|/home/[^/[:space:]'\''\"]+/)\\.aws/credentials['\''\"]?([;&|>[:space:]]|$)"; then
  block 'AWS credential file access is denied'
fi

if matches "(^|[;&|[:space:]])$file_access_command([[:space:]][^;&|]*)?[[:space:]<]+['\''\"]?(~[^/[:space:]'\''\"]*/|\\\$home/|/users/[^/[:space:]'\''\"]+/|/home/[^/[:space:]'\''\"]+/)\\.ssh(/|['\''\"]?([;&|>[:space:]]|$))"; then
  block 'SSH directory access is denied'
fi

if matches '(^|[;&|[:space:]])(sh|bash|zsh|dash)[[:space:]]+([^;&|[:space:]]+[[:space:]]+)*-[[:alpha:]]*c[[:alpha:]]*[[:space:]]+.*(\.env([^[:alnum:]_]|$)|secrets(/|[^[:alnum:]_]|$)|config/credentials\.json|\.pem([^[:alnum:]_]|$)|\.key([^[:alnum:]_]|$)|\.aws/credentials|\.ssh(/|[^[:alnum:]_]|$))'; then
  block 'nested shell secret access is denied'
fi

if matches '(^|[^[:alnum:]_])(prod|production)([^[:alnum:]_]|$)'; then
  block 'production-like target is denied by the baseline'
fi

exit 0
