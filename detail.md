# detail.md — ファイル構成リファレンス

「何があるか」の一覧。新規ファイル作成・大幅変更・削除・リネームのたびに更新する。

## ルート

### CLAUDE.md
- 役割: Claude Code が毎回読むプロジェクト説明とルール（モデル分業、管理ドキュメントの運用、プライバシー規則）
- 依存: aim.md、tasks/lessons.md、baton.md、docs/design.md を参照
- 参照元: Claude Code（自動読み込み）、.claude/agents/editor.md

### aim.md
- 役割: AI引き継ぎ用の最上位指針（概要・技術・設計方針・禁止事項・現在のフォーカス）
- 参照元: CLAUDE.md（セッション開始時に必読）

### update.md
- 役割: 進捗ログ（追記型・新しいものが上）。立案 → 進捗 → 完了
- 参照元: CLAUDE.md、baton.md

### detail.md
- 役割: このファイル。ファイルごとの役割・主要要素・依存関係

### baton.md
- 役割: 次セッションへの引き継ぎ（上書き型）
- 参照元: CLAUDE.md（セッション開始時に必読）

### teach.md
- 役割: 仕組みの解説書（面接で説明できることがゴール）。現在は第1章（データの流れ）、第2章（RLS）
- 依存: supabase/migrations/0001_init.sql、docs/adr/

### README.md
- 役割: GitHub 用の紹介とセットアップ手順
- 依存: example.env、docs/

### example.env
- 役割: 環境変数の見本（EXPO_PUBLIC_SUPABASE_URL、EXPO_PUBLIC_SUPABASE_ANON_KEY）。`.env` にコピーして使う
- 備考: `.env.*` は settings.json で読み取り禁止のため、この名前にしている

### .gitignore
- 役割: `.env`、鍵ファイル（*.p8 / *.jks / *.pem / *.mobileprovision）、node_modules、ルートの /ios /android、expo-env.d.ts などを除外

## アプリ本体（フェーズ2-1: Expo プロジェクト）

### package.json
- 役割: 依存関係とスクリプト。name `nicky`、`main: expo-router/entry`、jest preset `jest-expo`
- スクリプト: start / ios（expo run:ios）/ android（expo run:android）/ lint（eslint .）/ typecheck（tsc --noEmit）/ test（jest）
- 依存: Expo SDK 58、expo-router、react-dom（react と同じ 19.3.0 に固定。peer 解決用）ほか
- 参照元: npm、Expo CLI、Jest

### package-lock.json
- 役割: npm install が自動生成する依存バージョンの固定（手で編集しない）

### app.json
- 役割: Expo アプリ設定。name `Nicky`、scheme `nicky`（F-02 の招待リンク用）、bundleIdentifier / package は `com.koresawa03.nicky`、plugins に expo-router
- 参照元: Expo CLI、assets/

### tsconfig.json
- 役割: TypeScript 設定。`expo/tsconfig.base` を継承し strict、`types: ["jest"]`、`@/*` → `src/*`

### eslint.config.js
- 役割: ESLint 設定。`eslint-config-expo/flat` を使用。ios/ android/ supabase/ node_modules/ .expo/ dist/ を対象外

### assets/
- 役割: テンプレートのアイコン・スプラッシュ画像（icon / splash-icon / favicon / android-icon-foreground・background・monochrome の6枚。後で差し替え）
- 参照元: app.json

### app/_layout.tsx
- 役割: Expo Router のルートレイアウト（`Stack`）
- 依存: expo-router

### app/index.tsx
- 役割: 仮のホーム画面（S-xx、フェーズ2で置き換え）。「Nicky」と表示するだけ
- 参照元: __tests__/app/index.test.tsx

### __tests__/app/index.test.tsx
- 役割: ホーム画面が「Nicky」を表示するスモークテスト（RNTL）。app/ 配下はすべてルート扱いになるため、テストはリポジトリ直下の __tests__/ に置く
- 依存: @testing-library/react-native、app/index.tsx

### src/features/index.ts、src/lib/index.ts、src/db/index.ts、src/constants/index.ts
- 役割: フォルダ構成用の空の index（`export {};` と役割コメント）。中身は F-xx の実装から追加
- 参照元: なし（今のところ）

### modules/.gitkeep
- 役割: 自作ネイティブモジュール（Swift / Kotlin）置き場。空フォルダを残すためのファイル

## .claude/

### .claude/settings.json
- 役割: Claude Code の権限設定。lint / test / git の基本操作は許可、npm install・push・supabase は確認、`.env` の読み書きと force push は禁止

### .claude/agents/editor.md
- 役割: ファイル変更担当の Sonnet サブエージェント定義（model: sonnet）。報告形式と detail.md 更新義務を持つ
- 依存: CLAUDE.md、docs/design.md

### .claude/commands/adr.md
- 役割: `/adr <判断>` で docs/adr/ に ADR を作成するコマンド
- 依存: docs/adr/0000-template.md

### .claude/commands/explain.md
- 役割: `/explain <ファイル>` でコードを面接向けに解説するコマンド（コードは変更しない）

## docs/

### docs/design.md
- 役割: 設計書（仕様の正）。現在は置き場所の説明のみ。Claude の設計ドキュメントの Markdown 書き出しを貼る

### docs/prompts.md
- 役割: Claude Code に順番に渡すプロンプト集（0. リポジトリ理解 〜 7. タイムライン）

### docs/adr/0000-template.md
- 役割: ADR のテンプレート（状況 / 決定 / 検討した他の案 / 結果・影響）

### docs/adr/0002-no-app-usage-sharing.md
- 役割: ADR-0002「アプリ使用状況は相手に共有しない」の全文（記入例）

## tasks/

### tasks/todo.md
- 役割: フェーズごとのタスク一覧（機能IDつき）

### tasks/lessons.md
- 役割: ユーザーに修正された失敗と再発防止ルール

## supabase/migrations/

### supabase/migrations/0001_init.sql
- 役割: 初期スキーマ（設計書4章）
- テーブル: profiles、circles、circle_members、invites、entries、reactions（MVP）／point_ledger、decorations、user_decorations（v1.1）
- ビュー: point_balances（台帳の合計で残高を出す）
- 関数: is_member（RLS 判定）、create_circle、create_invite、accept_invite、exchange_decoration
- トリガー: entries_grant_points（タイトル10pt・ひとこと5pt、1日1回）、reactions_grant_points（2pt、1日10ptまで）
- RLS: 全テーブル有効。point_ledger と invites はアプリから書き込み不可
- 依存: Supabase の auth.users、auth.uid()、extensions.gen_random_bytes
- 参照元: teach.md 第2章
- 未実装: delete_account（Storage 削除が絡むため Edge Function で実装予定）
