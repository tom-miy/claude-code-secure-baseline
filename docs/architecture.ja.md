# Architecture

この repository は Claude Code hardening baseline です。目的は Claude Code がローカル環境で実行できる command、file access、network access、hook を制限することです。

## レイヤ分離

```text
Claude Code hardening
  -> Claude Code が実行できる tool / command / file / network を制限する

agent-privacy-guard
  -> 外部 LLM に送る prompt を sanitize し、response を posthook で検査する
```

対象 repository では次のように分けます。

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

`.claude/` は Claude Code の実行権限制御、`.agent-privacy-guard/` は gateway policy です。この repository では `.agent-privacy-guard/` を生成しません。

## 防御ポイント

- sandbox: Bash command の filesystem / network 境界を作る
- permissions: Claude Code tool の allow / ask / deny を設定する
- hooks: PreToolUse で command を検査する
- Managed Settings: 組織が上書きしにくい policy を配布する
- devcontainer: host machine と workspace の境界を補助する

これらは重ねて使う前提です。hook だけ、devcontainer だけ、deny rule だけに依存しないでください。
