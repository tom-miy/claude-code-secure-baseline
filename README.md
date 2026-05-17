# claude-code-secure-baseline

This repository is a Claude Code hardening baseline.
It is not agent-privacy-guard.
It does not sanitize prompts.
It restricts what Claude Code can do locally.

Use this repository as the source for Claude Code sandboxing, permissions, deny rules, PreToolUse hooks, Managed Settings examples, and devcontainer examples. Do not copy the entire repository into an application repository. Copy the specific `.claude/` files you need, or run the installer.

## Why This Is Useful

Claude Code is powerful because it can inspect files and run local commands. That is also the risk. This hardening baseline gives each app repository a small, reviewable safety layer before Claude Code touches local files, shells out, or reaches the network.

What you get:

- A new app can adopt a known starting policy in one command.
- Dangerous Bash commands are blocked before they run.
- Secret files are denied by explicit rules instead of relying on memory.
- Network access is written down as an allowlist, not left implicit.
- Teams can review `.claude/settings.json` like normal source code.
- `CLAUDE.md` and a small skill example add project guidance for high-risk work.
- Organization policy can move into Managed Settings when project settings are not enough.

## Where These Files Go

The settings that actually affect Claude Code for an app live inside that app repository.

```text
your-app/
  CLAUDE.md
  .claude/
    settings.json
    hooks/
      validate-command.sh
    skills/
      db-change-review/
        skill.md
```

This repository is the source repository for the hardening files and installer. It is not meant to be copied wholesale into `your-app`.

Use OS-level Managed Settings only when you want organization-wide or machine-wide enforcement:

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

## Quick Start: Action and Result

| Action | What happens |
| --- | --- |
| Run `./examples/demo.sh` | The sample hook receives fake Claude Code Bash tool inputs. `rm -rf`, `curl ... \| sh`, and a destructive database command are blocked with exit code `2`; `git status` is allowed with exit code `0`. |
| Run `./install.sh --target /path/to/your-app` | The target app gets `CLAUDE.md`, `.claude/settings.json`, `.claude/hooks/validate-command.sh`, and `.claude/skills/db-change-review/skill.md`. Existing files are skipped. |
| Run `./install.sh --target /path/to/your-app --force` | The same files are installed, overwriting existing target files. |
| Start Claude Code in the target app | Claude Code reads `.claude/settings.json`, applies sandbox / permission examples, and runs the PreToolUse hook before Bash commands. |
| Claude Code tries `rm -rf`, `curl ... \| sh`, `git push --force`, `chmod 777`, or a `prod` command | The hook prints a reason to stderr and exits with code `2`, so Claude Code blocks the Bash tool call. |
| Claude Code tries to read `.env`, `secrets/**`, private keys, or credential paths | The permission, sandbox, and Bash hook examples reject those reads. |

## Typical Flow

```text
1. Run this in this repository:
   ./install.sh --target /path/to/your-app

2. This appears in your app repository:
   your-app/.claude/settings.json
   your-app/.claude/hooks/validate-command.sh
   your-app/.claude/skills/db-change-review/skill.md
   your-app/CLAUDE.md

3. Open Claude Code inside your app repository.

4. When Claude Code asks to run a Bash command:
   settings.json applies permission rules
   validate-command.sh checks the command before execution

5. If the command matches the deny patterns:
   Claude Code blocks the tool call before the command runs
```

The practical win is not that this makes Claude Code secure by magic. The win is that each repository starts with explicit, inspectable execution boundaries instead of ad hoc prompts and memory.

The hook checks the command text Claude Code is about to run. It does not expand shell aliases, shell functions, or wrapper scripts. For example, if `nuke` is an alias for `rm -rf`, the hook sees `nuke path`, not the expanded `rm -rf path`. Keep sandbox, permissions, and Managed Settings enabled so hidden behavior is still constrained at runtime.

## Before You Rely on It

After installing this baseline into an app repository:

- Keep Claude Code itself updated with the official installation and update path for your environment.
- Run Claude Code inside the target app and check `/status` for the active sandbox state.
- Check `/permissions` to confirm the expected deny, ask, allow, hook, and Managed Settings rules are active.
- Review any existing `.claude/` files before trusting an unknown repository.
- Review MCP servers, plugins, and skills before enabling them, and prefer organization-managed allowlists for shared environments.

## What This Covers

- Claude Code sandbox examples
- Claude Code permission deny rules
- sensitive file read deny rules
- network allowlist examples
- bypass permissions mode disabled
- PreToolUse Bash command validation hook
- project `CLAUDE.md` guidance example
- high-risk database change skill example
- unknown repository trust checklist for `.claude/` files
- managed settings example for organization policy
- minimal devcontainer isolation sample

## What This Does Not Cover

This is not a prompt sanitization gateway. It does not implement outbound prompt anonymization, reversible placeholder mapping, LLM gateway routing, MCP trust routing, response posthook inspection, or multi-agent policy enforcement. Those belong to a separate layer such as `agent-privacy-guard`.

This repository also complements `secure-dev-hooks`. This repository focuses on Claude Code runtime hardening: sandbox, permissions, Managed Settings, and Claude Code hooks. `secure-dev-hooks` focuses on development workflow hooks such as repository checks, git hooks, and validation scripts around normal development operations.

## Repository Layout

```text
README.md
README.ja.md
install.sh

claude/
  CLAUDE.example.md
  settings.example.json
  managed-settings.example.json
  hooks/
    validate-command.sh
  skills/
    db-change-review/
      skill.md

devcontainer/
  devcontainer.json
  Dockerfile

docs/
  ...

examples/
  demo.sh
  unsafe-db-tool-input.json
  unsafe-rm-tool-input.json
  unsafe-tool-input.json
  safe-tool-input.json

scripts/
  lint.sh
```

## Docs by Purpose

| Need | English | Japanese |
| --- | --- | --- |
| Understand the repository boundary and layer split | [architecture.md](docs/architecture.md) | [architecture.ja.md](docs/architecture.ja.md) |
| Tune `.claude/settings.json` for an app repository | [settings.md](docs/settings.md) | [settings.ja.md](docs/settings.ja.md) |
| Understand what the PreToolUse hook blocks | [hooks.md](docs/hooks.md) | [hooks.ja.md](docs/hooks.ja.md) |
| Roll out organization-level policy | [managed-settings.md](docs/managed-settings.md) | [managed-settings.ja.md](docs/managed-settings.ja.md) |
| Run Claude Code inside a devcontainer boundary | [devcontainer.md](docs/devcontainer.md) | [devcontainer.ja.md](docs/devcontainer.ja.md) |
| Review unknown repositories, MCP, plugins, skills, and production-adjacent work | [operational-guardrails.md](docs/operational-guardrails.md) | [operational-guardrails.ja.md](docs/operational-guardrails.ja.md) |
| Separate this repo from `agent-privacy-guard` | [integration-with-agent-privacy-guard.md](docs/integration-with-agent-privacy-guard.md) | [integration-with-agent-privacy-guard.ja.md](docs/integration-with-agent-privacy-guard.ja.md) |
| Use this repo with `secure-dev-hooks` | [integration-with-secure-dev-hooks.md](docs/integration-with-secure-dev-hooks.md) | [integration-with-secure-dev-hooks.ja.md](docs/integration-with-secure-dev-hooks.ja.md) |

## Install Into an App Repository

```bash
./install.sh --target /path/to/your-app
```

Result: only the Claude Code hardening files are copied into the target app.

This creates:

```text
your-app/
  CLAUDE.md
  .claude/
    settings.json
    hooks/
      validate-command.sh
    skills/
      db-change-review/
        skill.md
```

`CLAUDE.md` and `.claude/skills/db-change-review/skill.md` are guidance examples. They help Claude Code pause and ask for approval on high-risk work. Enforcement still belongs to settings, sandboxing, Managed Settings, and hooks.

`scripts/lint.sh` and `examples/demo.sh` are for this baseline repository only. They are not installed into the target app. `lint.sh` checks the files maintained in this repository, including the runnable demo.

Existing files are not overwritten by default.

```bash
./install.sh --target /path/to/your-app --force
```

Result: existing target files are overwritten with the hardening examples.

## Demo

```bash
./examples/demo.sh
```

Result: the demo passes sample Claude Code PreToolUse JSON into `claude/hooks/validate-command.sh`.

```text
unsafe rm -rf     -> blocked, exit code 2
unsafe curl pipe  -> blocked, exit code 2
unsafe db command -> blocked, exit code 2
safe git status   -> allowed, exit code 0
```

Keeping the demo under `examples/` makes the intent clearer: it is sample input plus a runnable scenario, not a repository maintenance task. `scripts/` is reserved for project upkeep such as linting and CI helpers.

The demo uses color when stdout is a TTY. Set `NO_COLOR=1` to disable color.

## Shell Portability

The `.sh` files in this repository are Bash scripts, not POSIX `sh` scripts. Run them as executables, for example `./examples/demo.sh`, or explicitly with `bash`.

Do not run them as `sh ./examples/demo.sh`. macOS and Linux can use different `/bin/sh` implementations, and Linux `/bin/sh` may not support Bash options such as `pipefail`.

## Security Notes

- Claude Code settings schema can change. Confirm active behavior with official Claude Code docs, `/status`, and `/permissions`.
- Deny rules are treated as higher priority than ask and allow rules.
- Managed Settings are for rules you want to enforce outside a single app repository.
- Devcontainers help separate the app workspace from your host machine. They still need the Claude Code settings and hooks in this repository.
- This repository is intentionally small: it provides example settings, hooks, docs, and an installer. It does not monitor the whole machine or inspect every possible data leak.

## References

- Claude Code settings: https://code.claude.com/docs/en/settings
- Claude Code hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
