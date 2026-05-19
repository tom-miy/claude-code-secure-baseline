# Devcontainer による分離

`devcontainer/` は Claude Code を分離された devcontainer で動かすための最小サンプルです。

```text
devcontainer/
  devcontainer.json
  Dockerfile
```

## 目的

- ホストマシンからの隔離
- 作業領域の境界の明確化
- ツールチェーンの固定
- ネットワーク許可リスト / ファイアウォールの補助

このサンプルは意図的に小さくしています。アプリの作業領域をコンテナに入れる例であり、完全なネットワークファイアウォールではありません。

## 含めているもの

- `jq`
- `shellcheck`
- `git`
- `curl`
- `ca-certificates`

`runArgs` では capability drop と `no-new-privileges` を設定しています。必要に応じてプロジェクト側で追加の強化を行ってください。

## 注意

devcontainer はアプリの作業領域とホストマシンを分けるための補助です。Claude Code の権限設定、サンドボックス、PreToolUse フック、管理設定が必要な場合は、それらも別途設定してください。
