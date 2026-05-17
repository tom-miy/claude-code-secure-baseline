# claude-code-secure-baseline

この repository は Claude Code hardening baseline です。
prompt 匿名化や outbound gateway は agent-privacy-guard の責務です。

この repository は、Claude Code がローカルで実行できる tool、command、file、network を制限するための設定例と installer を置く repository です。アプリ repository に丸ごとコピーするものではありません。必要な `.claude/` 設定だけをコピーするか、`install.sh` で配置します。

## 何が嬉しいのか

Claude Code は file を読み、local command を実行できるので強力です。同時に、そこがリスクにもなります。この hardening baseline は、Claude Code が file、shell、network に触れる前に、app repository ごとの小さく review しやすい安全層を置くためのものです。

嬉しいこと:

- 新しい app repository に、既知の starting policy を 1 command で入れられる。
- 危険な Bash command を実行前に block できる。
- `.env` や private key などの secret file を「気をつける」ではなく deny rule として明示できる。
- network access を暗黙にせず、allowlist として見える場所に置ける。
- `.claude/settings.json` を通常の source code と同じように review できる。
- `CLAUDE.md` と小さな skill example で high-risk work 向けの guidance を置ける。
- project settings で足りない場合は、Managed Settings で組織や端末単位に強制できる。

## どこに置くのか

実際に Claude Code に効かせる設定は、メイン app の repository 内に置きます。

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
```

この repository は hardening file と installer の配布元です。`your-app` に丸ごとコピーする前提ではありません。

組織全体や端末単位で強制したい設定は、app repo ではなく OS 側の Managed Settings に置きます。

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

## Quick Start: どうすると何が起こるか

| 操作 | 起こること |
| --- | --- |
| `./examples/demo.sh` を実行する | fake の Claude Code Bash tool input を hook に渡します。`rm -rf`、`curl ... \| sh`、destructive database command は exit code `2` で block、`git status` は exit code `0` で allow されます。 |
| `./install.sh --target /path/to/your-app` を実行する | 対象 app に `CLAUDE.md`、`.claude/settings.json`、`.claude/hooks/validate-command.sh`、`.claude/skills/db-change-review/skill.md` を配置します。既存 file は上書きしません。 |
| `./install.sh --target /path/to/your-app --force` を実行する | 同じ file を配置し、対象 app の既存 file を上書きします。 |
| 対象 app で Claude Code を起動する | Claude Code が `.claude/settings.json` を読み、sandbox / permissions の例を適用し、Bash command の前に PreToolUse hook を実行します。 |
| Claude Code が `rm -rf`、`curl ... \| sh`、`git push --force`、`chmod 777`、`prod` 系 command を実行しようとする | hook が stderr に理由を出して exit code `2` で終了し、Claude Code が Bash tool call を block します。 |
| Claude Code が `.env`、`secrets/**`、private key、credential path を読もうとする | permissions、sandbox、Bash hook の deny 例により read が拒否されます。 |

## 典型的な流れ

```text
1. この repository で実行する:
   ./install.sh --target /path/to/your-app

2. app repository にこれが作られる:
   your-app/.claude/settings.json
   your-app/.claude/hooks/validate-command.sh
   your-app/.claude/skills/db-change-review/skill.md
   your-app/CLAUDE.md

3. your-app の中で Claude Code を起動する。

4. Claude Code が Bash command を実行しようとする:
   settings.json の permission rule が効く
   validate-command.sh が実行前に command を検査する

5. command が deny pattern に一致する:
   command が実行される前に Claude Code の tool call が block される
```

実用上の嬉しさは、「これだけで魔法のように安全になる」ことではありません。各 repository が、曖昧な注意や prompt に頼らず、明示的で review 可能な実行境界を持てることです。

hook が検査するのは、Claude Code が実行しようとしている command text です。shell alias、shell function、wrapper script の中身までは展開しません。たとえば `nuke` が `rm -rf` の alias でも、hook から見えるのは `nuke path` であり、展開後の `rm -rf path` ではありません。そのため sandbox、permissions、Managed Settings も併用して、隠れた挙動を実行時の境界で制限します。

## 使い始める前に確認すること

この baseline を app repository に入れたあと、次を確認します。

- Claude Code 本体は、利用環境向けの公式 installation / update 手順で最新に保つ。
- 対象 app で Claude Code を起動し、`/status` で sandbox の有効状態を確認する。
- `/permissions` で deny / ask / allow / hook / Managed Settings が期待通り有効か確認する。
- 未知の repository を trust する前に、既存の `.claude/` file を review する。
- MCP server、plugin、skill は有効化前に確認し、shared environment では組織管理の allowlist を優先する。

## 対象範囲

- Claude Code sandbox の設定例
- Claude Code permissions の deny rule
- secret file read deny rule
- network allowlist の例
- bypass permissions mode の無効化
- PreToolUse Bash command validation hook
- project `CLAUDE.md` guidance example
- high-risk database change skill example
- unknown repository trust 向けの `.claude/` 確認 checklist
- 組織向け Managed Settings 例
- 最小構成の devcontainer isolation

## 対象外

この repository は prompt sanitization gateway ではありません。outbound prompt anonymization、reversible placeholder mapping、LLM gateway routing、MCP trust routing、response posthook inspection、multi-agent policy enforcement は実装しません。それらは `agent-privacy-guard` のような別レイヤの責務です。

この repository は `secure-dev-hooks` と補完関係にあります。この repository は Claude Code runtime hardening、つまり sandbox、permissions、Managed Settings、Claude Code hooks に集中します。`secure-dev-hooks` は repository check、git hooks、通常の開発操作の前後で使う validation script など、development workflow hooks を扱います。

## インストール

```bash
./install.sh --target /path/to/your-app
```

起こること: Claude Code hardening に必要な file だけを対象 app に配置します。

作成される layout:

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
```

`CLAUDE.md` と `.claude/skills/db-change-review/skill.md` は guidance example です。high-risk work で Claude Code に立ち止まって承認を求めさせるための補助であり、enforcement は settings、sandbox、Managed Settings、hooks が担います。

`scripts/lint.sh` と `examples/demo.sh` は、この baseline repository 自体のための file です。対象 app には install されません。`lint.sh` は、この repository で管理している JSON / shell script を検査するための script なので、runnable example である `examples/demo.sh` も lint 対象に含めています。

既存 file はデフォルトで上書きしません。上書きする場合:

```bash
./install.sh --target /path/to/your-app --force
```

起こること: 対象 app の既存 file を hardening example で上書きします。

## Demo

```bash
./examples/demo.sh
```

起こること: `examples/unsafe-rm-tool-input.json`、`examples/unsafe-tool-input.json`、`examples/unsafe-db-tool-input.json`、`examples/safe-tool-input.json` を `validate-command.sh` に渡します。

```text
unsafe rm -rf     -> block, exit code 2
unsafe curl pipe  -> block, exit code 2
unsafe db command -> block, exit code 2
safe git status   -> allow, exit code 0
```

demo を `examples/` に置くと、sample input と実行シナリオが同じ場所にまとまります。`scripts/` は lint や CI 補助のような repository maintenance 用に寄せられるため、利用者が「見るための例」と「運用のための script」を迷わず区別できます。

demo は stdout が TTY のときだけ色を使います。色を無効化する場合は `NO_COLOR=1` を指定してください。

## Shell portability

この repository の `.sh` file は POSIX `sh` script ではなく Bash script です。`./examples/demo.sh` のように実行権限つきで実行するか、明示的に `bash` で実行してください。

`sh ./examples/demo.sh` のようには実行しないでください。macOS と Linux では `/bin/sh` の実体が異なることがあり、Linux の `/bin/sh` では `pipefail` などの Bash option が使えない場合があります。

## Docs

目的別に読む file を選びます。

| 目的 | English | Japanese |
| --- | --- | --- |
| repository の境界と layer split を理解する | [architecture.md](docs/architecture.md) | [architecture.ja.md](docs/architecture.ja.md) |
| app repository 向けに `.claude/settings.json` を調整する | [settings.md](docs/settings.md) | [settings.ja.md](docs/settings.ja.md) |
| PreToolUse hook が何を block するか理解する | [hooks.md](docs/hooks.md) | [hooks.ja.md](docs/hooks.ja.md) |
| 組織レベルの policy を配布する | [managed-settings.md](docs/managed-settings.md) | [managed-settings.ja.md](docs/managed-settings.ja.md) |
| devcontainer 境界内で Claude Code を使う | [devcontainer.md](docs/devcontainer.md) | [devcontainer.ja.md](docs/devcontainer.ja.md) |
| 未知 repository、MCP、plugin、skill、production-adjacent work を review する | [operational-guardrails.md](docs/operational-guardrails.md) | [operational-guardrails.ja.md](docs/operational-guardrails.ja.md) |
| `agent-privacy-guard` との責務を分ける | [integration-with-agent-privacy-guard.md](docs/integration-with-agent-privacy-guard.md) | [integration-with-agent-privacy-guard.ja.md](docs/integration-with-agent-privacy-guard.ja.md) |
| `secure-dev-hooks` と併用する | [integration-with-secure-dev-hooks.md](docs/integration-with-secure-dev-hooks.md) | [integration-with-secure-dev-hooks.ja.md](docs/integration-with-secure-dev-hooks.ja.md) |

## 注意

- Claude Code の設定 schema は変更される可能性があります。実運用前に公式 docs、`/status`、`/permissions` で確認してください。
- deny rule は ask / allow より優先される前提で扱います。
- Managed Settings は、単一の app repository の外側で強制したい rule に使います。
- devcontainer は app workspace と host machine を分けるための補助です。Claude Code の settings / hooks は別途必要です。
- この repository が提供するのは設定例、hook、docs、installer です。machine 全体の監視や、あらゆる情報漏えいの検査までは行いません。

## References

- Claude Code settings: https://code.claude.com/docs/en/settings
- Claude Code hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
