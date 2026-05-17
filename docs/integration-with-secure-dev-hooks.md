# Integration With secure-dev-hooks

This repository complements `secure-dev-hooks`.

## claude-code-secure-baseline

Controls what Claude Code can do at runtime.

- Claude Code sandbox
- Claude Code permissions
- Claude Code deny rules
- Claude Code PreToolUse hooks
- Managed Settings
- devcontainer examples

## secure-dev-hooks

Controls development workflow checks around a repository.

- git hooks
- repository checks
- validation scripts
- checks that run before or after normal development operations

## How They Fit Together

```text
claude-code-secure-baseline
  -> limits Claude Code runtime behavior

secure-dev-hooks
  -> validates development workflow behavior
```

Use this repository when the question is "what should Claude Code be allowed to do?" Use `secure-dev-hooks` when the question is "what should this repository's development workflow allow?"

## Responsibility Map

| Need | Primary place |
| --- | --- |
| Block Claude Code from reading `.env`, private keys, or cloud credentials | `claude-code-secure-baseline` |
| Block Claude Code from running dangerous Bash commands | `claude-code-secure-baseline` |
| Keep Claude Code MCP server and hook policy organization-managed | `claude-code-secure-baseline` Managed Settings |
| Block credentials from being committed | `secure-dev-hooks` |
| Warn on dangerous AI-generated diffs before commit or push | `secure-dev-hooks` |
| Require CODEOWNERS review or protected branches before merge | GitHub repository settings |
| Minimize GitHub Actions token permissions | GitHub workflow files and repository settings |

They can be used together in the same app repository, but they should stay separate:

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

`install.sh` in this repository installs only `.claude/`. It does not install git hooks or general workflow validation scripts.
