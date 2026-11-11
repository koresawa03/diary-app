# （アプリ名未定）— 書かない交換日記

スマホのデータから1日が自動でまとまり、友達や恋人と交換できる日記アプリ（iOS / Android）。
寝る前にタイトルを付けるだけ。月末には「ふたりの振り返り」カードができます。

> 開発中です。スクリーンショットはフェーズ3完了後に追加予定。

## 特徴
- **書かなくても続く**: 写真・訪問した場所・歩数・聴いた曲から下書きを自動生成し、締め時刻に自動で交換
- **プライバシー重視**: 位置の履歴や写真の原本はサーバーに送らず、本人が選んだ要約だけを共有
- **振り返り**: 月ごとにタイトル一覧やよく行った場所をカードにまとめる

## 技術構成
Expo（React Native）/ TypeScript / Supabase（PostgreSQL, Auth, Storage）/ Swift・Kotlin（ネイティブモジュール）

## ドキュメント
- [設計書](docs/design.md)
- [設計判断の記録（ADR）](docs/adr/)
- [進捗ログ](update.md) / [プロジェクト指針](aim.md) / [仕組みの解説](teach.md)

## セットアップ
```bash
cp example.env .env   # Supabase の URL と anon key を記入
npm install
npx expo run:ios      # または npx expo run:android
```
