# Devcontainer Isolation

`devcontainer/` is a minimal sample for running Claude Code inside an isolated devcontainer.

```text
devcontainer/
  devcontainer.json
  Dockerfile
```

## Goals

- separate the workspace from the host machine
- make the workspace boundary explicit
- pin a small toolchain
- supplement network allowlists or firewall rules

This sample is intentionally small. It shows how to put the app workspace in a container, but it is not a complete network firewall.

## Included Tools

- `jq`
- `shellcheck`
- `git`
- `curl`
- `ca-certificates`

The `runArgs` drop container capabilities and enable `no-new-privileges`. Add project-specific hardening as needed.

## Caveat

A devcontainer helps separate the app workspace from the host machine. It still needs Claude Code permissions, sandboxing, PreToolUse hooks, and Managed Settings when those controls are required.
