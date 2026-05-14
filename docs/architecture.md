# Architecture

This repository is a Claude Code hardening baseline. Its purpose is to restrict the commands, file access, network access, and hooks that Claude Code can use in a local development environment.

## Layer Separation

```text
Claude Code hardening
  -> Restricts the tools, commands, files, and network access Claude Code can use

agent-privacy-guard
  -> Sanitizes prompts sent to external LLMs and inspects responses with posthooks
```

Use separate directories in an application repository:

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh

  .agent-privacy-guard/
    policy.yaml
    hooks/
      prehook.sh
      posthook.sh
```

`.claude/` controls Claude Code execution permissions. `.agent-privacy-guard/` controls gateway policy. This repository does not generate `.agent-privacy-guard/`.

## Defense Points

- sandbox: creates filesystem and network boundaries for Bash commands
- permissions: configures Claude Code tool allow / ask / deny rules
- hooks: validates commands with PreToolUse
- Managed Settings: distributes policy that is harder for users to override
- devcontainer: helps separate the host machine from the workspace

These layers are meant to be used together. Do not rely on only hooks, only devcontainers, or only deny rules.
