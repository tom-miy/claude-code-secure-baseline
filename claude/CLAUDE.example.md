# Claude Code Project Guardrails

This project uses Claude Code with repository-local hardening settings.

## Security Rules

- Do not print environment variable values, token values, API keys, cookies, private keys, or session secrets.
- Do not add credentials, tokens, or private keys to source code, tests, fixtures, logs, screenshots, or docs.
- Do not log personal data or customer data unless the user explicitly asks for a safe redacted example.
- Do not run destructive database operations without an explicit human approval step.
- Do not operate on production systems unless the user clearly confirms the target, scope, and rollback plan.
- Do not send raw secrets or personal data in HTTP requests, issue comments, commit messages, or pull request descriptions.

## Production Data

- Treat `.env.production`, `secrets/`, credential files, private keys, and cloud credentials as out of scope.
- Use `.env.example` or documented dummy values when configuration examples are needed.
- Prefer deployment systems such as CI/CD environment variables or hosting-provider secret stores for production values.

## High-Risk Changes

Before database changes, permission changes, deployment changes, or production-adjacent work:

1. State the intended operation.
2. Identify the affected system, environment, table, path, or service.
3. Describe the expected blast radius.
4. Identify a verification step.
5. Ask for human approval before executing the high-risk operation.

These instructions are guidance for Claude Code behavior. Enforcement still belongs to `.claude/settings.json`, Managed Settings, sandboxing, and hooks.
