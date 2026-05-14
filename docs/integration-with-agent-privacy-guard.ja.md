# Integration With agent-privacy-guard

この repository は `agent-privacy-guard` とは別物です。責務を混ぜないことが重要です。

## claude-code-secure-baseline

Claude Code 自体の local execution を制限します。

- sandbox
- permissions
- deny rules
- PreToolUse hooks
- network / filesystem restrictions
- Managed Settings
- devcontainer isolation

## agent-privacy-guard

外部 LLM に送る prompt と response を gateway layer で制御します。

- prompt sanitization
- outbound gateway
- structured placeholder mapping
- response posthook inspection
- multi-agent policy enforcement

## 併用 layout

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

`.claude/settings.json` は Claude Code がどの command / file / network に触れるかを制限します。`.agent-privacy-guard/policy.yaml` は prompt や response の gateway policy を扱います。

この repository の `install.sh` は `.claude/` だけを配置します。`.agent-privacy-guard/` は作成しません。
