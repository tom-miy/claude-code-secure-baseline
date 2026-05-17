# Operational Guardrails

This repository focuses on Claude Code runtime hardening. It also includes project guidance examples that complement settings and hooks.

## Why There Is No `.claudeignore` Example

This repository uses Claude Code settings for sensitive file protection:

- `permissions.deny`
- sandbox `filesystem.denyRead`
- Bash PreToolUse checks for common secret paths

This keeps the baseline in Claude Code's project settings model and makes the active policy visible in `.claude/settings.json`.

If an organization already uses `.claudeignore`, it can keep doing so, but this repository does not depend on it. The baseline source of truth here is `.claude/settings.json`.

## CLAUDE.md

`claude/CLAUDE.example.md` is a project memory example. It is not an enforcement mechanism. It gives Claude Code project-specific guidance such as:

- do not print secret values
- do not hard-code credentials
- do not log personal or customer data
- require explicit approval for production-adjacent operations

Use it as a starting point and adapt it to the target app's domain.

## Production Environment Values

Keep production values outside the app workspace whenever possible.

Recommended layout:

```text
your-app/
  .env.example          # dummy values, safe to read
  .env                  # local development only, denied by this baseline
  secrets/              # denied by this baseline
    .env.production     # production-like values, not for Claude Code
```

For deployment, prefer CI/CD environment variables or the hosting provider's secret store. Claude Code should work from examples, local dummy values, or documented configuration names instead of raw production values.

## Unknown Repository Trust Check

Before trusting a repository you did not create, inspect its Claude Code files first. This baseline is meant to make those files reviewable, but a repository can still contain its own local policy.

Check:

- `.claude/settings.json` for broad `allow` rules, disabled sandboxing, or relaxed bypass settings
- `.claude/hooks/` for scripts that run before or after tool use
- `.claude/skills/` for instructions that encourage external calls, production access, or credential handling
- MCP server definitions for unknown endpoints or commands
- project `CLAUDE.md` for guidance that conflicts with your team policy

If the repository has surprising `.claude/` behavior, do not trust it until the effective settings are understood with `/status` and `/permissions`.

## MCP, Plugins, and Skills

MCP servers, plugins, and skills extend what Claude Code can do or how it behaves. This repository does not implement MCP trust routing. It provides local Claude Code hardening examples around runtime permissions and hooks.

For shared environments:

- prefer known or official MCP servers, plugins, and skills
- keep MCP server configuration small and reviewable
- use Managed Settings such as `allowManagedMcpServersOnly` when organization policy must control the allowed set
- treat a skill as guidance, not enforcement

## Skills

`claude/skills/db-change-review/skill.md` is a lightweight approval-flow example for high-risk database work.

Skills guide behavior. They do not replace permissions, sandboxing, hooks, or human review. Use them when the desired behavior is "pause, summarize impact, and ask for approval" rather than "block the tool call unconditionally."
