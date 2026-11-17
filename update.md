# update.md — 進捗ログ（新しいものが上）

## 2026-11-17 16:12 — フェーズ2-1: Expo プロジェクトの作成
**立案**
- 依頼: Expo（TypeScript strict + Expo Router）の土台を作り、lint / typecheck / test が回る状態にする
- 計画: `blank-typescript`（SDK 58）テンプレートを一時フォルダに作り、package.json / app.json / tsconfig.json / assets/ だけをリポジトリ直下へ。Expo Router・ESLint・Jest・RNTL を追加し、app/ と src/ の最小構成、スモークテストを作る
- 影響範囲: リポジトリ直下（package.json, app.json, tsconfig.json, eslint.config.js, assets/）、app/、src/、modules/、.gitignore、detail.md、tasks/todo.md、README.md

**進捗**
- 完了: 上記ファイルを作成。lint / typecheck / test / expo-doctor（20/20）すべて通過
- 補足: npm 12 では `expo install` が失敗するため、Expo 推奨バージョンで `npm install` を直接実行。react-dom を 19.3.0 に固定（peer 解決用）。テストは app/ がルート扱いになるため `__tests__/app/` に配置
- 残課題: iOS / Android の実機起動確認（ユーザー）、Android SDK 未導入（Android Studio のインストールが必要）
- ブロッカー: なし

**完了** ✅

## 2026-11-11 18:30 — リポジトリの初期セットアップ ✅ 完了
**立案**
- 依頼: 設計書をもとに、Claude Code で開発を始められるリポジトリの土台を作る
- 計画: CLAUDE.md、管理ドキュメント（aim / update / detail / baton / teach / tasks）、Supabase の初期マイグレーション、Claude Code の設定とコマンドを用意する
- 影響範囲: リポジトリ全体（コードはまだなし）

**進捗**
- 完了: CLAUDE.md、`.claude/`（settings / agents / commands）、`supabase/migrations/0001_init.sql`（ローカルの PostgreSQL で RLS・招待・ポイント付与の動作を確認済み）、docs/adr、管理ドキュメント一式
- 残課題: `docs/design.md` に設計書の Markdown 書き出しを貼る（手作業）
- ブロッカー: なし

**完了**
- 次は tasks/todo.md のフェーズ2から着手
