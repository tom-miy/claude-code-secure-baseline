# secure-dev-hooks との連携

このリポジトリは `secure-dev-hooks` と補完関係にあります。

## claude-code-secure-baseline

Claude Code が実行時に何をできるかを制限します。

- Claude Code サンドボックス
- Claude Code 権限設定
- Claude Code 拒否ルール
- Claude Code PreToolUse フック
- 管理設定
- devcontainer の例

## secure-dev-hooks

リポジトリの開発ワークフローを検査します。

- git フック
- リポジトリ検査
- 検証スクリプト
- 通常の開発操作の前後で実行する検査

## 関係

```text
claude-code-secure-baseline
  -> Claude Code の実行時の挙動を制限する

secure-dev-hooks
  -> 開発ワークフローの挙動を検査する
```

「Claude Code に何を許可するか」を扱う場合はこのリポジトリを使います。「このリポジトリの開発ワークフローで何を許可するか」を扱う場合は `secure-dev-hooks` を使います。

## 責務の対応表

| やりたいこと | 主な置き場所 |
| --- | --- |
| Claude Code が `.env`、秘密鍵、クラウド認証情報を読むのを止める | `claude-code-secure-baseline` |
| Claude Code が危険な Bash コマンドを実行するのを止める | `claude-code-secure-baseline` |
| Claude Code の MCP サーバー / フックポリシーを組織管理にする | `claude-code-secure-baseline` の管理設定 |
| 認証情報がコミットされるのを止める | `secure-dev-hooks` |
| AI が生成した差分の危険変更をコミット / プッシュ前に警告する | `secure-dev-hooks` |
| CODEOWNERS レビューや保護ブランチをマージ条件にする | GitHub リポジトリ設定 |
| GitHub Actions トークン権限を最小化する | GitHub Actions ワークフローファイルとリポジトリ設定 |

同じアプリのリポジトリで併用できますが、責務は分けます。

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh

  .githooks/
    pre-commit
    pre-push

  scripts/
    validate-*.sh
```

このリポジトリの `install.sh` が配置するのは `.claude/` だけです。git フックや一般的なワークフロー検証スクリプトはインストールしません。
