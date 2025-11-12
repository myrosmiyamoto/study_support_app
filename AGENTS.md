# Repository Guidelines

## Project Structure & Module Organization
study_support_app は Flutter 3.x を前提としたマルチプラットフォーム構成です。`lib/main.dart` が MaterialApp とホームメニューを束ね、機能画面は `lib/screens/pomodoro_screen.dart`（タイマー制御）と `lib/screens/similar_problem_screen.dart`（OpenAI 連携）に分離します。UI リソースは `lib/` 配下で完結し、プラットフォーム固有コードは `android/`, `ios/`, `web/`, `windows/` など各ディレクトリに配置します。テストは `test/widget_test.dart` を起点に機能別サブフォルダを追加してください。

## Build, Test, and Development Commands
- `flutter pub get` : 依存関係の取得・更新。
- `flutter run -d chrome --dart-define=OPENAI_API_KEY=sk-...` : Web 実行例。デバイス ID を差し替えれば iOS/Android も同様。
- `flutter test` : 単体・ウィジェットテストの実行。
- `flutter test --coverage` : カバレッジ生成。`coverage/lcov.info` を CI に渡します。
- `flutter analyze && dart format lib test` : 静的解析と自動整形。

## Coding Style & Naming Conventions
`analysis_options.yaml` で `flutter_lints` を採用しています。2 スペースインデント、PascalCase の Widget クラス、camelCase のメソッド・変数を徹底してください。再利用できる Widget/定数は `const` コンストラクタで宣言し、UI テキストは今後の i18n を見据えて集中管理ファイル化を検討します。

## Testing Guidelines
`flutter_test` と `WidgetTester` を使い、画面ごとに `test/<feature>/<name>_test.dart` を作成します。ポモドーロはタイマー遷移、類題生成は API 成功・失敗の状態遷移を検証してください。非同期処理は `pump` / `pumpAndSettle` でフレームを進め、ネットワーク呼び出しは `http.Client` のモックで切り替えます。PR 前に `flutter test --coverage` の成功スクリーンショットを添付します。

## Commit & Pull Request Guidelines
現状 Git 履歴は未整備のため、Conventional Commits（例: `feat(pomodoro): allow custom durations`）で統一してください。PR には 1) 目的と背景、2) 実装概要と影響範囲、3) テスト結果、4) UI 変更はスクリーンショットまたは短い動画、5) 関連 Issue/タスクへのリンクを含めます。

## Security & Configuration Tips
OpenAI Vision 呼び出しは `OPENAI_API_KEY` を `--dart-define` で注入し、`.gitignore` 済みファイルに平文キーを置かないでください。カメラ機能を利用するため `android/app/src/main/AndroidManifest.xml` と `ios/Runner/Info.plist` に権限説明を必ず追記し、鍵やシークレットはローカル環境変数または CI のシークレットストアで管理します。
