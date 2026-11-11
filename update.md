# update.md — 進捗ログ（新しいものが上）

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
