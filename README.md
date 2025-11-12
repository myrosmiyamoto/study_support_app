# study_support_app

## 概要
ポモドーロ・テクニックによる集中学習タイマーと、撮影した問題から類題を生成する OpenAI 連携機能を備えた Flutter 3 系アプリです。Web・モバイル・デスクトップで共通 UI を提供し、画像は Vision 対応モデルへ送信して解説付きの演習問題を生成します。

## 主な機能
- ポモドーロタイマー：作業・休憩サイクルを視覚的に管理。
- 類題生成：カメラ撮影／ギャラリー選択した問題画像を gpt-4o-mini へ送信し、日本語の新規問題＋解説を取得。
- マルチプラットフォーム対応：`lib/` 配下で UI を完結させ、各 OS 向けフォルダからビルド可能。

## 開発環境
- Flutter 3.x（Dart SDK 3.9 以降）
- OpenAI API キー（Vision 対応権限付き）
- 推奨 CLI：`flutter` コマンドが利用可能な PowerShell / macOS Terminal

## セットアップと動作確認
1. 依存関係の取得
   ```powershell
   flutter pub get
   ```
2. OpenAI キー設定
   `.env.example` をコピーし、`OPENAI_API_KEY` を設定します。
   ```powershell
   cp .env.example .env
   # .env を編集して実キーを記入
   ```
3. ローカル実行（例：Chrome）
   ```powershell
   flutter run -d chrome
   ```
   Android/iOS で実行する場合は `-d <device_id>` を変更してください。`--dart-define=OPENAI_API_KEY=...` を併用すれば `.env` より優先されます。
4. テスト
   ```powershell
   flutter test
   ```

## Android 端末へ導入する方法
### 開発ビルド（USB デバッグ）
1. 端末でデベロッパーモードと USB デバッグを有効化。
2. PC と USB 接続し、`flutter devices` で端末を確認。
3. 下記コマンドでデバッグビルドを転送・起動。
   ```powershell
   flutter run -d <android_device_id>
   ```

### APK 生成と配布
1. 署名情報（`key.properties` など）を設定済みであることを確認。
2. リリース APK をビルド。
   ```powershell
   flutter build apk --release
   ```
   `.env` を使わない場合は `--dart-define=OPENAI_API_KEY=...` を付与してください。
3. 生成物は `build/app/outputs/flutter-apk/app-release.apk`。端末へコピーし、ファイルマネージャ経由でインストールするか、ADB を利用します。
   ```powershell
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

### Google Play 配信メモ
- `flutter build appbundle --release` で AAB を作成し、Play Console にアップロード。
- OpenAI API キーはコードにハードコードせず、`.env` or CI シークレットから注入してください。

## トラブルシューティング
- `.env` が読み込まれない場合：`lib/main.dart` で `dotenv.load` を実行しているため、アプリ直下に `.env` があるか確認。
- カメラ利用時の権限：`android/app/src/main/AndroidManifest.xml` と `ios/Runner/Info.plist` の権限説明文を最新化してください。

## ライセンス
本リポジトリにはライセンスが設定されていません。必要に応じて `LICENSE` を追加してください。
