# claude-code-secure-baseline

このリポジトリは、Claude Code を安全に使うための実行権限制御の基準です。
プロンプト匿名化や外向きゲートウェイは agent-privacy-guard の責務です。

このリポジトリは、Claude Code がローカルで実行できるツール、コマンド、ファイル、ネットワークを制限するための設定例とインストーラを置くリポジトリです。アプリのリポジトリに丸ごとコピーするものではありません。必要な `.claude/` 設定だけをコピーするか、`install.sh` で配置します。

## 何が嬉しいのか

Claude Code はファイルを読み、ローカルコマンドを実行できるので強力です。同時に、そこがリスクにもなります。この基準は、Claude Code がファイル、シェル、ネットワークに触れる前に、アプリのリポジトリごとの小さくレビューしやすい安全層を置くためのものです。

嬉しいこと:

- 新しいアプリのリポジトリに、既知の初期ポリシーを 1 コマンドで入れられる。
- 危険な Bash コマンドを実行前に止められる。
- `.env` や秘密鍵などの機密ファイルを「気をつける」ではなく拒否ルールとして明示できる。
- ネットワークアクセスを暗黙にせず、許可リストとして見える場所に置ける。
- `.claude/settings.json` を通常のソースコードと同じようにレビューできる。
- `CLAUDE.md` と小さなスキル例で、高リスク作業向けの指示を置ける。
- プロジェクト設定で足りない場合は、管理設定で組織や端末単位に強制できる。

## どこに置くのか

実際に Claude Code に効かせる設定は、メインアプリのリポジトリ内に置きます。

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

このリポジトリは、強化設定ファイルとインストーラの配布元です。`your-app` に丸ごとコピーする前提ではありません。

組織全体や端末単位で強制したい設定は、アプリのリポジトリではなく OS 側の管理設定に置きます。

```text
macOS: /Library/Application Support/ClaudeCode/managed-settings.json
Linux: /etc/claude-code/managed-settings.json
Windows: C:\Program Files\ClaudeCode\managed-settings.json
```

## はじめに: どうすると何が起こるか

| 操作 | 起こること |
| --- | --- |
| `./examples/demo.sh` を実行する | 疑似的な Claude Code Bash ツール入力をフックに渡します。`rm -rf`、`curl ... \| sh`、破壊的なデータベースコマンドは終了コード `2` で拒否され、`git status` は終了コード `0` で許可されます。 |
| `./install.sh --target /path/to/your-app` を実行する | 対象アプリに `CLAUDE.md`、`.claude/settings.json`、`.claude/hooks/validate-command.sh`、`.claude/skills/db-change-review/skill.md` を配置します。既存ファイルは上書きしません。 |
| `./install.sh --target /path/to/your-app --force` を実行する | 同じファイルを配置し、対象アプリの既存ファイルを上書きします。 |
| 対象アプリで Claude Code を起動する | Claude Code が `.claude/settings.json` を読み、サンドボックスと権限設定の例を適用し、Bash コマンドの前に PreToolUse フックを実行します。 |
| Claude Code が `rm -rf`、`curl ... \| sh`、`git push --force`、`chmod 777`、`prod` 系コマンドを実行しようとする | フックが stderr に理由を出して終了コード `2` で終了し、Claude Code が Bash ツール呼び出しを拒否します。 |
| Claude Code が `.env`、`secrets/**`、秘密鍵、認証情報パスを読もうとする | 権限設定、サンドボックス、Bash フックの拒否例により読み取りが拒否されます。 |

## 典型的な流れ

```text
1. このリポジトリで実行する:
   ./install.sh --target /path/to/your-app

2. アプリのリポジトリにこれが作られる:
   your-app/.claude/settings.json
   your-app/.claude/hooks/validate-command.sh
   your-app/.claude/skills/db-change-review/skill.md
   your-app/CLAUDE.md

3. your-app の中で Claude Code を起動する。

4. Claude Code が Bash コマンドを実行しようとする:
   settings.json の権限ルールが効く
   validate-command.sh が実行前にコマンドを検査する

5. コマンドが拒否パターンに一致する:
   コマンドが実行される前に Claude Code のツール呼び出しが拒否される
```

実用上の嬉しさは、「これだけで魔法のように安全になる」ことではありません。各リポジトリが、曖昧な注意やプロンプトに頼らず、明示的でレビュー可能な実行境界を持てることです。

フックが検査するのは、Claude Code が実行しようとしているコマンド文字列です。シェルエイリアス、シェル関数、ラッパースクリプトの中身までは展開しません。たとえば `nuke` が `rm -rf` のエイリアスでも、フックから見えるのは `nuke path` であり、展開後の `rm -rf path` ではありません。そのためサンドボックス、権限設定、管理設定も併用して、隠れた挙動を実行時の境界で制限します。

## 使い始める前に確認すること

この基準をアプリのリポジトリに入れたあと、次を確認します。

- Claude Code 本体は、利用環境向けの公式インストール / 更新手順で最新に保つ。
- 対象アプリで Claude Code を起動し、`/status` でサンドボックスの有効状態を確認する。
- `/permissions` で拒否 / 確認 / 許可 / フック / 管理設定が期待通り有効か確認する。
- 未知のリポジトリを信頼する前に、既存の `.claude/` ファイルをレビューする。
- MCP サーバー、プラグイン、スキルは有効化前に確認し、共有環境では組織管理の許可リストを優先する。

## 対象範囲

- Claude Code サンドボックスの設定例
- Claude Code 権限設定の拒否ルール
- 機密ファイル読み取り拒否ルール
- ネットワーク許可リストの例
- 権限バイパスモードの無効化
- PreToolUse Bash コマンド検証フック
- プロジェクト `CLAUDE.md` の指示例
- 高リスクなデータベース変更向けのスキル例
- 未知のリポジトリを信頼する前の `.claude/` 確認チェックリスト
- 組織向け管理設定の例
- 最小構成の devcontainer 分離

## 対象外

このリポジトリはプロンプト匿名化ゲートウェイではありません。外向きプロンプト匿名化、可逆プレースホルダ対応表、LLM ゲートウェイの経路制御、MCP 信頼経路制御、応答の後段検査、複数エージェントのポリシー強制は実装しません。それらは `agent-privacy-guard` のような別レイヤの責務です。

このリポジトリは `secure-dev-hooks` と補完関係にあります。このリポジトリは Claude Code の実行時制御、つまりサンドボックス、権限設定、管理設定、Claude Code フックに集中します。`secure-dev-hooks` はリポジトリ検査、git フック、通常の開発操作の前後で使う検証スクリプトなど、開発ワークフローのフックを扱います。

## インストール

```bash
./install.sh --target /path/to/your-app
```

起こること: Claude Code の実行権限制御に必要なファイルだけを対象アプリに配置します。

作成される配置:

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

`CLAUDE.md` と `.claude/skills/db-change-review/skill.md` は指示例です。高リスク作業で Claude Code に立ち止まって承認を求めさせるための補助であり、強制は設定、サンドボックス、管理設定、フックが担います。

`scripts/lint.sh` と `examples/demo.sh` は、この基準リポジトリ自体のためのファイルです。対象アプリにはインストールされません。`lint.sh` は、このリポジトリで管理している JSON / シェルスクリプトを検査するためのスクリプトなので、実行できる例である `examples/demo.sh` も検査対象に含めています。

既存ファイルはデフォルトで上書きしません。上書きする場合:

```bash
./install.sh --target /path/to/your-app --force
```

起こること: 対象アプリの既存ファイルを実行権限制御の例で上書きします。

## デモ

```bash
./examples/demo.sh
```

起こること: `examples/unsafe-rm-tool-input.json`、`examples/unsafe-tool-input.json`、`examples/unsafe-db-tool-input.json`、`examples/safe-tool-input.json` を `validate-command.sh` に渡します。

```text
unsafe rm -rf     -> 拒否、終了コード 2
unsafe curl pipe  -> 拒否、終了コード 2
unsafe db command -> 拒否、終了コード 2
safe git status   -> 許可、終了コード 0
```

デモを `examples/` に置くと、サンプル入力と実行シナリオが同じ場所にまとまります。`scripts/` は lint や CI 補助のようなリポジトリ保守用に寄せられるため、利用者が「見るための例」と「運用のためのスクリプト」を迷わず区別できます。

デモは stdout が TTY のときだけ色を使います。色を無効化する場合は `NO_COLOR=1` を指定してください。

## シェルの互換性

このリポジトリの `.sh` ファイルは POSIX `sh` スクリプトではなく Bash スクリプトです。`./examples/demo.sh` のように実行権限つきで実行するか、明示的に `bash` で実行してください。

`sh ./examples/demo.sh` のようには実行しないでください。macOS と Linux では `/bin/sh` の実体が異なることがあり、Linux の `/bin/sh` では `pipefail` などの Bash オプションが使えない場合があります。

## ドキュメント

目的別に読むファイルを選びます。

| 目的 | 英語版 | 日本語版 |
| --- | --- | --- |
| リポジトリの境界とレイヤ分離を理解する | [architecture.md](docs/architecture.md) | [architecture.ja.md](docs/architecture.ja.md) |
| アプリのリポジトリ向けに `.claude/settings.json` を調整する | [settings.md](docs/settings.md) | [settings.ja.md](docs/settings.ja.md) |
| PreToolUse フックが何を拒否するか理解する | [hooks.md](docs/hooks.md) | [hooks.ja.md](docs/hooks.ja.md) |
| 組織レベルのポリシーを配布する | [managed-settings.md](docs/managed-settings.md) | [managed-settings.ja.md](docs/managed-settings.ja.md) |
| devcontainer 境界内で Claude Code を使う | [devcontainer.md](docs/devcontainer.md) | [devcontainer.ja.md](docs/devcontainer.ja.md) |
| 未知のリポジトリ、MCP、プラグイン、スキル、本番に近い作業をレビューする | [operational-guardrails.md](docs/operational-guardrails.md) | [operational-guardrails.ja.md](docs/operational-guardrails.ja.md) |
| `agent-privacy-guard` との責務を分ける | [integration-with-agent-privacy-guard.md](docs/integration-with-agent-privacy-guard.md) | [integration-with-agent-privacy-guard.ja.md](docs/integration-with-agent-privacy-guard.ja.md) |
| `secure-dev-hooks` と併用する | [integration-with-secure-dev-hooks.md](docs/integration-with-secure-dev-hooks.md) | [integration-with-secure-dev-hooks.ja.md](docs/integration-with-secure-dev-hooks.ja.md) |

## 注意

- Claude Code の設定スキーマは変更される可能性があります。実運用前に公式ドキュメント、`/status`、`/permissions` で確認してください。
- 拒否ルールは確認 / 許可ルールより優先される前提で扱います。
- 管理設定は、単一のアプリリポジトリの外側で強制したいルールに使います。
- devcontainer はアプリの作業領域とホストマシンを分けるための補助です。Claude Code の設定 / フックは別途必要です。
- このリポジトリが提供するのは設定例、フック、ドキュメント、インストーラです。マシン全体の監視や、あらゆる情報漏えいの検査までは行いません。

## 参考

- Claude Code 設定: https://code.claude.com/docs/en/settings
- Claude Code フック: https://docs.anthropic.com/en/docs/claude-code/hooks
