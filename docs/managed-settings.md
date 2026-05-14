# Managed Settings

`claude/managed-settings.example.json` is a sample Managed Settings file for organizations.

## Install Locations

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

Managed Settings have higher precedence than user and project settings, which makes them suitable for organization-enforced policy.

Use project settings inside the main app repository for app-specific policy. Use Managed Settings outside the app repository only when the policy should apply across an organization or machine.

## Included Examples

- `permissions.disableBypassPermissionsMode`
- `allowManagedPermissionRulesOnly`
- `allowManagedHooksOnly`
- `allowManagedMcpServersOnly`
- `sandbox.network.allowManagedDomainsOnly`
- managed network allowlist
- secret file read denies
- dangerous command denies

## Operations Notes

When `allowManagedPermissionRulesOnly` is enabled, user and project permission rules are ignored and only managed rules apply. Use it when policy enforcement matters more than per-team flexibility.

`allowManagedHooksOnly` blocks user and project hooks. Use it when command validation or other hook behavior must be fixed by the organization.

The managed settings example points the hook to `/usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh` instead of a project-local `.claude/hooks` path. Install the hook there, or change the path to another centrally managed location before rollout:

```bash
sudo install -d -m 0755 /usr/local/lib/claude-code-secure-baseline/hooks
sudo install -m 0755 claude/hooks/validate-command.sh /usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh
```

`sandbox.network.allowManagedDomainsOnly` respects only managed allowed domains and ignores allowed domains from other scopes. Denied domains are still respected.

## Caveat

Managed Settings are powerful, but the settings schema can change as Claude Code evolves. Before rollout, test with a small group and verify behavior with `/status` and `/permissions`.
