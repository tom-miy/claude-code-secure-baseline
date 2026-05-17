# Integration With secure-dev-hooks

この repository は `secure-dev-hooks` と補完関係にあります。

## claude-code-secure-baseline

Claude Code が runtime で何をできるかを制限します。

- Claude Code sandbox
- Claude Code permissions
- Claude Code deny rules
- Claude Code PreToolUse hooks
- Managed Settings
- devcontainer examples

## secure-dev-hooks

repository の development workflow を検査します。

- git hooks
- repository checks
- validation scripts
- 通常の開発操作の前後で実行する checks

## 関係

```text
claude-code-secure-baseline
  -> Claude Code runtime behavior を制限する

secure-dev-hooks
  -> development workflow behavior を検査する
```

「Claude Code に何を許可するか」を扱う場合はこの repository を使います。「この repository の開発 workflow で何を許可するか」を扱う場合は `secure-dev-hooks` を使います。

## 責務の対応表

| やりたいこと | 主な置き場所 |
| --- | --- |
| Claude Code が `.env`、private key、cloud credentials を読むのを止める | `claude-code-secure-baseline` |
| Claude Code が危険な Bash command を実行するのを止める | `claude-code-secure-baseline` |
| Claude Code の MCP server / hook policy を組織管理にする | `claude-code-secure-baseline` の Managed Settings |
| credentials が commit されるのを止める | `secure-dev-hooks` |
| AI-generated diff の危険変更を commit / push 前に警告する | `secure-dev-hooks` |
| CODEOWNERS review や protected branch を merge 条件にする | GitHub repository settings |
| GitHub Actions token permission を最小化する | GitHub workflow file と repository settings |

同じ app repository で併用できますが、責務は分けます。

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh

  .githooks/
    pre-commit
    pre-push

  scripts/
    validate-*.sh
```

この repository の `install.sh` が配置するのは `.claude/` だけです。git hooks や一般的な workflow validation script は install しません。
