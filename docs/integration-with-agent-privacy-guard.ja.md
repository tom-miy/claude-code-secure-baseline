# agent-privacy-guard との連携

このリポジトリは `agent-privacy-guard` とは別物です。責務を混ぜないことが重要です。

## claude-code-secure-baseline

Claude Code 自体のローカル実行を制限します。

- サンドボックス
- 権限設定
- 拒否ルール
- PreToolUse フック
- ネットワーク / ファイルシステム制限
- 管理設定
- devcontainer による分離

## agent-privacy-guard

外部 LLM に送るプロンプトと応答をゲートウェイ層で制御します。

- プロンプトの無害化
- 外向きゲートウェイ
- 構造化されたプレースホルダ対応表
- 応答の後段検査
- 複数エージェントのポリシー強制

## 併用時の配置

```text
your-app/
  .claude/
    settings.json
    hooks/
      validate-command.sh

  .agent-privacy-guard/
    policy.yaml
    hooks/
      prehook.sh
      posthook.sh
```

`.claude/settings.json` は Claude Code がどのコマンド / ファイル / ネットワークに触れるかを制限します。`.agent-privacy-guard/policy.yaml` はプロンプトや応答のゲートウェイポリシーを扱います。

このリポジトリの `install.sh` は `.claude/` だけを配置します。`.agent-privacy-guard/` は作成しません。
