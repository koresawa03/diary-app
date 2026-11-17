# todo.md — タスク

## フェーズ1: 設計
- [x] 設計書（docs/design.md）の作成
- [x] 初期マイグレーション（supabase/migrations/0001_init.sql）
- [x] Claude Code の設定と管理ドキュメント
- [ ] 設計書の Markdown 書き出しを docs/design.md に貼る（ユーザー作業）
- [ ] ワイヤーフレーム（S-01〜S-10）

## フェーズ2: 土台づくり
- [x] Expo プロジェクト作成（TypeScript strict、Expo Router、lint / typecheck / test スクリプト）
- [ ] `src/lib/date.ts`: 午前4時区切りの entry_date と締め判定（境界値テストつき）
- [ ] `src/constants/`: 文字数上限・締め時刻・ポイント数などの定数
- [ ] Supabase プロジェクト作成とマイグレーション適用（ユーザー作業 + 手順書）
- [ ] F-01 サインイン（Apple / Google）、S-02、profiles の作成
- [ ] F-02 ペア招待（create_circle / create_invite / accept_invite）、S-03、エラー表示
- [ ] 完了確認: iPhone と Android の2台でペアになれる

## フェーズ3: 自動日記
- [ ] F-03 下書き生成（iOS: 写真・訪問記録・歩数）→ expo-sqlite
- [ ] F-03 Android 版
- [ ] F-05 共有項目の設定（S-05）
- [ ] F-04 タイトル・ひとこと、寝る前の通知
- [ ] F-05 自動送信（締め時刻・3日超の破棄）
- [ ] F-06 タイムライン（S-06、S-07）とスタンプ
