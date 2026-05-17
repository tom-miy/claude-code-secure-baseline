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

## Skills

`claude/skills/db-change-review/skill.md` is a lightweight approval-flow example for high-risk database work.

Skills guide behavior. They do not replace permissions, sandboxing, hooks, or human review. Use them when the desired behavior is "pause, summarize impact, and ask for approval" rather than "block the tool call unconditionally."
