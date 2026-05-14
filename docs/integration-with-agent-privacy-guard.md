# Integration With agent-privacy-guard

This repository is separate from `agent-privacy-guard`. Keep the responsibilities separate.

## claude-code-secure-baseline

Restricts Claude Code local execution.

- sandbox
- permissions
- deny rules
- PreToolUse hooks
- network / filesystem restrictions
- Managed Settings
- devcontainer isolation

## agent-privacy-guard

Controls prompts and responses at the gateway layer.

- prompt sanitization
- outbound gateway
- structured placeholder mapping
- response posthook inspection
- multi-agent policy enforcement

## Combined Layout

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

`.claude/settings.json` restricts which commands, files, and networks Claude Code can touch. `.agent-privacy-guard/policy.yaml` handles prompt and response gateway policy.

This repository's `install.sh` installs only `.claude/`. It does not create `.agent-privacy-guard/`.
