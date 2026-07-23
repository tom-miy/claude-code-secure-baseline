# アーキテクチャ

このリポジトリは、Claude Code を安全に使うための実行権限制御の基準です。目的は、Claude Code がローカル環境で実行できるコマンド、ファイルアクセス、ネットワークアクセスを、権限設定とフックで制限することです。

## レイヤ分離

```text
Claude Code の実行権限制御
  -> Claude Code が実行できるツール / コマンド / ファイル / ネットワークを制限する

agent-privacy-guard
  -> 外部 LLM に送るプロンプトを無害化し、応答を後段フックで検査する
```

対象リポジトリでは次のように分けます。

```text
your-app/
  CLAUDE.md
  .claude/
    settings.json
    hooks/
      validate-command.sh
    skills/
      db-change-review/
        skill.md

  .agent-privacy-guard/
```

`CLAUDE.md` と `.claude/` は Claude Code の実行権限制御で、`install.sh` が配置するファイルです。`.agent-privacy-guard/` はゲートウェイポリシーで、このリポジトリでは生成しません。内部構成は [integration-with-agent-privacy-guard.ja.md](integration-with-agent-privacy-guard.ja.md) を参照してください。

## 防御ポイント

- サンドボックス: Bash コマンドのファイルシステム / ネットワーク境界を作る
- 権限設定: Claude Code ツールの許可 / 確認 / 拒否を設定する
- フック: PreToolUse でコマンドを検査する
- 管理設定: 組織が配布し、利用者やプロジェクト設定では上書きしにくいポリシーを強制する
- devcontainer: ホストマシンと作業領域の境界を補助する

これらは重ねて使う前提です。フックだけ、devcontainer だけ、拒否ルールだけに依存しないでください。
