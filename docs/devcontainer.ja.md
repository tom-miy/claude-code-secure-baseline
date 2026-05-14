# Devcontainer Isolation

`devcontainer/` は Claude Code を isolated devcontainer で動かすための最小 sample です。

```text
devcontainer/
  devcontainer.json
  Dockerfile
```

## 目的

- host machine からの隔離
- workspace boundary の明確化
- toolchain の固定
- network allowlist / firewall の補助

この sample は意図的に小さくしています。app workspace を container に入れる例であり、完全な network firewall ではありません。

## 含めているもの

- `jq`
- `shellcheck`
- `git`
- `curl`
- `ca-certificates`

`runArgs` では capability drop と `no-new-privileges` を設定しています。必要に応じて project 側で追加 hardening を行ってください。

## 注意

devcontainer は app workspace と host machine を分けるための補助です。Claude Code permissions、sandbox、PreToolUse hook、Managed Settings が必要な場合は、それらも別途設定してください。
