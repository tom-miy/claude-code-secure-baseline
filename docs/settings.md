# Claude Code Settings

`claude/settings.example.json` is an example intended to be installed as `.claude/settings.json` in an application repository.

The active project settings belong in the main app repository where Claude Code is being used:

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh
```

Keep this repository as the source for the hardening files. Install or copy only the needed `.claude/` files into each app repository.

## Sandbox

```json
{
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": false
  }
}
```

`allowUnsandboxedCommands: false` disables the escape hatch for running Bash commands outside the sandbox. Sandbox implementation details and constraints differ across macOS, Linux, and WSL2, so verify the active state with Claude Code `/status` before production use.

`failIfUnavailable` is set to `true` so Claude Code stops when sandboxing is unavailable. This is less convenient on unsupported environments, but it avoids silently running Bash commands without the expected sandbox boundary.

## Permissions

`permissions.deny` includes examples that reject dangerous commands and secret file reads.

Examples:

- `rm -rf`
- `curl`
- `wget`
- `git push`
- `chmod 777`
- `.env`
- `secrets/**`
- `**/*.pem`
- `~/.aws/credentials`
- `~/.ssh/**`

Design these settings with the assumption that deny rules take precedence over ask and allow rules. `permissions.allow` is intentionally limited to a small set of safe commands.

The example also denies Bash commands that reference common secret paths. This is intentionally conservative because shell-based reads such as `cat .env` do not go through the Claude Code `Read` tool.

## Network Allowlist

`sandbox.network.allowedDomains` includes common development domains:

- `github.com`
- `*.githubusercontent.com`
- `*.npmjs.org`
- `registry.yarnpkg.com`
- `pypi.org`
- `files.pythonhosted.org`

The operating model is deny by default. Add only the domains required by the project, and block production or sensitive systems with `deniedDomains` or hooks.

## Bypass Permissions

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

This disables bypass permissions mode, including the equivalent of `--dangerously-skip-permissions`. Put this setting in Managed Settings when an organization needs to make it difficult for users or project settings to override.
