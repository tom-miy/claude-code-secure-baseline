# 管理設定

`claude/managed-settings.example.json` は組織向け管理設定のサンプルです。

## 配置先

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

管理設定は通常のユーザー / プロジェクト設定より高い優先度を持ち、組織ポリシーを強制する用途に向いています。

アプリごとのポリシーはメインアプリのリポジトリ内の `.claude/settings.json` に置きます。管理設定はアプリのリポジトリの外側に置き、組織全体または端末単位でポリシーを強制したい場合に使います。

## 含めている例

- `permissions.disableBypassPermissionsMode`
- `allowManagedPermissionRulesOnly`
- `allowManagedHooksOnly`
- `allowManagedMcpServersOnly`
- `sandbox.network.allowManagedDomainsOnly`
- 管理されたネットワーク許可リスト
- 機密ファイル読み取り拒否
- 危険コマンド拒否

## 運用メモ

`allowManagedPermissionRulesOnly` を有効にすると、ユーザー / プロジェクト設定の権限ルールは使われず、管理設定のルールだけが有効になります。チームごとの柔軟性よりも組織ポリシーの強制を優先する場合に使います。

`allowManagedHooksOnly` はユーザー / プロジェクトのフックを拒否するため、フックを使った追加検査を組織側で固定したい場合に使います。

管理設定の例では、フックをプロジェクトローカルな `.claude/hooks` ではなく `/usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh` に向けています。展開前にその場所へフックを配置するか、組織で管理する別の絶対パスに変更してください。

```bash
sudo install -d -m 0755 /usr/local/lib/claude-code-secure-baseline/hooks
sudo install -m 0755 claude/hooks/validate-command.sh /usr/local/lib/claude-code-secure-baseline/hooks/validate-command.sh
```

`sandbox.network.allowManagedDomainsOnly` は管理設定のドメイン許可リストだけを尊重し、他スコープの許可ドメインを無視します。拒否ドメインは引き続き尊重されます。

## 注意

管理設定は強力ですが、設定スキーマは Claude Code 側のバージョンに追従が必要です。配布前に小さいグループで `/status` と `/permissions` を確認してください。
