# Managed Settings

`claude/managed-settings.example.json` は組織向け Managed Settings の sample です。

## 配置先

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

Managed Settings は通常の user / project settings より高い precedence を持ち、組織 policy を強制する用途に向いています。

app ごとの policy はメイン app repository 内の `.claude/settings.json` に置きます。Managed Settings は app repository の外側に置き、組織全体または端末単位で policy を強制したい場合に使います。

## 含めている例

- `permissions.disableBypassPermissionsMode`
- `allowManagedPermissionRulesOnly`
- `allowManagedHooksOnly`
- `allowManagedMcpServersOnly`
- `sandbox.network.allowManagedDomainsOnly`
- managed network allowlist
- secret file read deny
- dangerous command deny

## 運用メモ

`allowManagedPermissionRulesOnly` を有効にすると、user / project settings の permission rule は使われず、managed settings の rule だけが有効になります。チームごとの柔軟性よりも組織 policy の強制を優先する場合に使います。

`allowManagedHooksOnly` は user / project hook を block するため、hook を使った追加検査を組織側で固定したい場合に使います。

managed settings example では、hook を project-local な `.claude/hooks` ではなく `/usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh` に向けています。rollout 前にその場所へ hook を配置するか、組織で管理する別の absolute path に変更してください。

```bash
sudo install -d -m 0755 /usr/local/lib/claude-code-secure-baseline/hooks
sudo install -m 0755 claude/hooks/validate-command.sh /usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh
```

`sandbox.network.allowManagedDomainsOnly` は managed settings の domain allowlist だけを尊重し、他 scope の allowed domain を無視します。deny domain は引き続き尊重されます。

## 注意

Managed Settings は強力ですが、設定 schema は Claude Code 側の version に追従が必要です。配布前に小さい group で `/status` と `/permissions` を確認してください。
