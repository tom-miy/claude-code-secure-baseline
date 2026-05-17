# Operational Guardrails

この repository は Claude Code runtime hardening に集中します。そのうえで、settings や hooks を補助する project guidance の例も置きます。

## `.claudeignore` example を置かない理由

この repository では、secret file protection を Claude Code settings 側で扱います。

- `permissions.deny`
- sandbox の `filesystem.denyRead`
- common secret path を検出する Bash PreToolUse hook

これにより、active な policy を `.claude/settings.json` に集約できます。

既に組織で `.claudeignore` を使っている場合は併用して構いません。ただし、この repository の baseline は `.claudeignore` に依存しません。ここでの source of truth は `.claude/settings.json` です。

## CLAUDE.md

`claude/CLAUDE.example.md` は project memory の例です。これは enforcement mechanism ではありません。Claude Code に対して、project-specific な行動指針を与えます。

- secret value を出力しない
- credential を source code に埋め込まない
- personal data / customer data を log に出さない
- production-adjacent operation では明示的な承認を要求する

target app の domain に合わせて編集して使います。

## Production Environment Values

production value は、可能な限り app workspace の外で管理します。

推奨 layout:

```text
your-app/
  .env.example          # dummy value。Claude Code が読んでよい
  .env                  # local development only。この baseline では deny
  secrets/              # この baseline では deny
    .env.production     # production-like value。Claude Code の対象外
```

deployment には CI/CD environment variables や hosting provider の secret store を使います。Claude Code には raw production value ではなく、example、local dummy value、設定名の docs を見せます。

## Skills

`claude/skills/db-change-review/skill.md` は high-risk database work 向けの軽量な approval-flow example です。

Skills は behavior guidance です。permissions、sandbox、hooks、人間の review の代替ではありません。「tool call を無条件に block したい」場合ではなく、「一度止まり、影響範囲を整理し、承認を求めてほしい」場合に使います。
