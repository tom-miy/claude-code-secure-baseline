# Claude Code 設定

`claude/settings.example.json` は、アプリのリポジトリの `.claude/settings.json` に配置するための例です。

実際に有効になるプロジェクト設定は、Claude Code を使うメインアプリのリポジトリ内に置きます。

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh
```

このリポジトリは実行権限制御ファイルの配布元として扱います。各アプリのリポジトリには必要な `.claude/` ファイルだけをインストール / コピーします。

## サンドボックス

```json
{
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": false
  }
}
```

`allowUnsandboxedCommands: false` は、サンドボックスを外して Bash コマンドを実行する抜け道を無効化するための設定です。macOS、Linux、WSL2 でサンドボックスの実装や制約は異なるため、実運用前に Claude Code の `/status` でサンドボックスが有効になっているか確認してください。

`failIfUnavailable` は `true` にしています。サンドボックスが使えない環境では Claude Code が止まり、期待したサンドボックス境界なしに Bash コマンドが実行されることを避けます。未対応環境では不便になりますが、安全側に倒す設定です。

## 権限設定

`permissions.deny` では、危険コマンドと機密ファイル読み取りを拒否する例を置いています。

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

拒否ルールは確認 / 許可ルールより優先される前提で設計します。`permissions.allow` は最小限の安全なコマンドだけに絞っています。

この例では、一般的な機密パスを含む Bash コマンドも拒否しています。`cat .env` のようなシェル経由の読み取りは Claude Code の `Read` ツールを通らないため、意図的に保守的にしています。

## `.claudeignore` を使わない理由

このリポジトリでは、機密ファイルポリシーを別の ignore ファイルではなく `.claude/settings.json` に寄せています。

主な control は次の通りです。

- `permissions.deny`
- サンドボックスの `filesystem.denyRead`
- 一般的な機密パスを検出する Bash PreToolUse フック

これにより、各アプリのリポジトリにインストールされる Claude Code 設定ファイルの中で有効なポリシーを確認できます。

## 本番環境の値

Claude Code が読んでよいファイルには例の値やダミー値を置きます。本番環境の値はアプリの作業領域の外、またはこの基準で拒否されるパスに置きます。

推奨配置:

```text
your-app/
  .env.example          # ダミー値
  .env                  # ローカル用。この基準では拒否
  secrets/
    .env.production     # 本番に近い値。この基準では拒否
```

デプロイには CI/CD 環境変数やホスティングプロバイダのシークレットストアを使います。通常のコード変更に生の本番値は不要な状態にします。

## ネットワーク許可リスト

`sandbox.network.allowedDomains` に開発で必要になりやすいドメインを例示しています。

- `github.com`
- `*.githubusercontent.com`
- `*.npmjs.org`
- `registry.yarnpkg.com`
- `pypi.org`
- `files.pythonhosted.org`

考え方はデフォルト拒否です。必要なドメインを許可リストに追加し、本番や機密システムへの接続は `deniedDomains` やフックで別途拒否します。

## 権限バイパス

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

この設定は `--dangerously-skip-permissions` 相当のバイパスモードを無効化するためのものです。組織で強制したい場合は管理設定に置くと、ユーザーやプロジェクト設定で上書きしにくくなります。

## バージョンと実行時の確認

このリポジトリは Claude Code 本体を更新しません。Claude Code 本体は、利用環境向けの公式インストール / 更新手順で最新に保ちます。

アプリのリポジトリに基準をインストール / 変更したあと、次を確認します。

- 対象アプリのリポジトリから Claude Code を起動する
- `/status` でサンドボックスの有効状態を確認する
- `/permissions` で許可 / 確認 / 拒否 / フック / 管理設定の有効状態を確認する
- 本番に関わる作業に使う前に、現在の Claude Code 公式ドキュメントと有効な挙動を照合する
