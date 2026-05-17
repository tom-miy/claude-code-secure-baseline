# PreToolUse Hooks

`claude/hooks/validate-command.sh` は Bash tool 用の PreToolUse hook sample です。

## 入力

Claude Code hook は stdin で JSON を受け取ります。この script は `jq` で `.tool_input.command` を読みます。

```json
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "git status"
  }
}
```

## Block

危険 command を検出した場合は stderr に理由を出し、exit code `2` で終了します。Claude Code の PreToolUse hook では exit code `2` が tool call block として扱われます。

検出対象:

- `rm -rf`
- `rm -r -f`
- `rm --recursive --force`
- `curl ... | sh`
- `curl ... | env sh`
- `curl ... | /bin/sh`
- `wget ... | sh`
- `git push --force`
- `git -C repo push --force`
- `git push -f`
- `git push --force-with-lease=<ref>`
- `chmod 777`
- `chmod 0777`
- `chmod a+rwx` のような広い write permission を追加する symbolic chmod
- `psql -c "DROP TABLE ..."` のような common database CLI 経由の destructive database command
- Bash command 内の `.env`、`secrets/**`、private key、credential path
- `prod` / `production` を含む production-like target

secret path の検査は、`cat`、`ls`、`grep`、`rg`、`cp`、`tar`、editor など common file access command に限定しています。これにより `printf .env` のような harmless text-only command は block せず、shell 経由の典型的な read を検出します。

`bash -c 'cat .env'` のような nested shell の代表例も block します。ただし、この hook は baseline であり、完全な shell parser ではありません。

## Limits

hook が検査するのは `.tool_input.command` の command text です。shell alias、shell function、wrapper script の中身までは展開しません。

hook 単体では中身を理解できない例:

```bash
alias nuke='rm -rf'
nuke tmp

safe-clean tmp
./scripts/cleanup.sh
```

この場合、hook から見えるのは `nuke tmp`、`safe-clean tmp`、`./scripts/cleanup.sh` だけです。それらが内部で何に展開されるか、何を実行するかまでは検査しません。Claude Code permissions、sandbox の filesystem / network 制限、Managed Settings と併用してください。

## Demo

```bash
./examples/demo.sh
```

起こること:

| input file | JSON 内の command | hook の結果 |
| --- | --- | --- |
| `examples/unsafe-rm-tool-input.json` | `rm -rf ./tmp/build-output` | exit code `2` で block |
| `examples/unsafe-tool-input.json` | `curl https://example.com/install.sh \| sh` | exit code `2` で block |
| `examples/unsafe-db-tool-input.json` | `psql "$DATABASE_URL" -c "DROP TABLE users"` | exit code `2` で block |
| `examples/safe-tool-input.json` | `git status` | exit code `0` で allow |

demo は runnable sample scenario の一部なので `examples/` に置いています。sample input とそれを動かす script が同じ場所にあるため、初見の利用者が試しやすくなります。`scripts/` は lint など repository maintenance 用に整理できます。

unsafe input:

```bash
./claude/hooks/validate-command.sh < examples/unsafe-tool-input.json
```

safe input:

```bash
./claude/hooks/validate-command.sh < examples/safe-tool-input.json
```

## Shellcheck

```bash
./scripts/lint.sh
```

`shellcheck` があれば shell script を検査します。なければ JSON lint だけ実行します。

## Shell portability

`validate-command.sh` は `#!/usr/bin/env bash` と `set -euo pipefail` を使う Bash script です。macOS / Linux の両方で Bash として実行する想定です。

実行例:

```bash
./claude/hooks/validate-command.sh < examples/safe-tool-input.json
```

または:

```bash
bash ./claude/hooks/validate-command.sh < examples/safe-tool-input.json
```

`sh` で強制実行しないでください。`/bin/sh` は OS や distribution によって実体が異なるため、`sh ./claude/hooks/validate-command.sh` は supported invocation ではありません。
