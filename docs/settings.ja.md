# Claude Code Settings

`claude/settings.example.json` は、アプリ repository の `.claude/settings.json` に配置するための example です。

実際に有効になる project settings は、Claude Code を使うメイン app repository 内に置きます。

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh
```

この repository は hardening file の配布元として扱います。各 app repository には必要な `.claude/` file だけを install / copy します。

## Sandbox

```json
{
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": false
  }
}
```

`allowUnsandboxedCommands: false` は、sandbox を外して Bash command を実行する escape hatch を無効化するための設定です。macOS、Linux、WSL2 で sandbox の実装や制約は異なるため、実運用前に Claude Code の `/status` で sandbox が有効になっているか確認してください。

`failIfUnavailable` は `true` にしています。sandbox が使えない環境では Claude Code が止まり、期待した sandbox 境界なしに Bash command が実行されることを避けます。未対応環境では不便になりますが、安全側に倒す設定です。

## Permissions

`permissions.deny` では、危険 command と secret file read を拒否する例を置いています。

対象例:

- `rm -rf`
- `curl`
- `wget`
- `git push`
- `chmod 777`
- `.env`
- `secrets/**`
- `**/*.pem`
- `~/.aws/credentials`
- `~/.aws/config`
- `~/.aws/sso/cache/**`
- `~/.config/gcloud/**`
- `~/.kube/config`
- `~/.docker/config.json`
- `~/.netrc`
- `~/.npmrc`
- `~/.pypirc`
- `~/.gnupg/**`
- `~/.ssh/**`

deny rule は ask / allow より優先される前提で設計します。`permissions.allow` は最小限の safe command だけに絞っています。

この example では、common secret path を含む Bash command も deny しています。`cat .env` のような shell 経由の read は Claude Code の `Read` tool を通らないため、意図的に保守的にしています。

## `.claudeignore` を使わない理由

この repository では、secret file policy を別の ignore file ではなく `.claude/settings.json` に寄せています。

主な control は次の通りです。

- `permissions.deny`
- sandbox の `filesystem.denyRead`
- common secret path を検出する Bash PreToolUse hook

これにより、各 app repository に install される Claude Code settings file の中で active policy を確認できます。

## Production Environment Values

Claude Code が読んでよい file には example value や dummy value を置きます。production value は app workspace の外、またはこの baseline で deny される path に置きます。

推奨 layout:

```text
your-app/
  .env.example          # dummy value
  .env                  # local only。この baseline では deny
  secrets/
    .env.production     # production-like value。この baseline では deny
```

deployment には CI/CD environment variables や hosting provider の secret store を使います。通常の code change に raw production value は不要な状態にします。

## Network Allowlist

`sandbox.network.allowedDomains` に開発で必要になりやすい domain を例示しています。

- `github.com`
- `*.githubusercontent.com`
- `*.npmjs.org`
- `registry.yarnpkg.com`
- `pypi.org`
- `files.pythonhosted.org`

考え方は deny-by-default です。必要な domain を allowlist に追加し、production や sensitive system への接続は `deniedDomains` や hook で別途 block します。

## Bypass Permissions

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

この設定は `--dangerously-skip-permissions` 相当の bypass mode を無効化するためのものです。組織で強制したい場合は Managed Settings に置くと、ユーザーや project settings で上書きしにくくなります。

## Version と Runtime の確認

この repository は Claude Code 本体を更新しません。Claude Code 本体は、利用環境向けの公式 installation / update 手順で最新に保ちます。

app repository に baseline を install / 変更したあと、次を確認します。

- 対象 app repository から Claude Code を起動する
- `/status` で sandbox の有効状態を確認する
- `/permissions` で allow / ask / deny / hooks / Managed Settings の有効状態を確認する
- production work に使う前に、現在の Claude Code 公式 docs と active behavior を照合する
