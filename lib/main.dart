// Flutterの基本パッケージを読み込み（アプリ画面を作るために必要）
import 'package:flutter/material.dart';

// Google Fonts パッケージを使って、日本語フォント（Noto Sans JP）を利用するため
import 'package:google_fonts/google_fonts.dart';

// 別ファイルの画面（ポモドーロタイマー画面）を読み込み
import 'screens/pomodoro_screen.dart';
// 別ファイルの画面（類題生成画面）を読み込み
import 'screens/similar_problem_screen.dart';

// アプリのスタート地点（main関数）
// runApp() に自分のアプリのクラス（StudySupportApp）を渡す
void main() {
  runApp(const StudySupportApp());
}

// StatelessWidget（状態を持たないウィジェット）を使ってアプリ全体を作るクラス
class StudySupportApp extends StatelessWidget {
  const StudySupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリ全体の見た目（テーマ）を設定する
    final baseTheme = ThemeData(
      useMaterial3: true, // Material Design 3（新しいデザインルール）を使う
      colorSchemeSeed: Colors.blue, // 全体のテーマカラー（青系）
    );

    return MaterialApp(
      title: '学習支援アプリ', // アプリのタイトル（設定上の名前）
      debugShowCheckedModeBanner: false, // デバッグ表示（右上の赤い帯）を消す
      // Google Fontsで日本語フォントを使う設定
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.notoSansJpTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      // アプリ起動時に最初に表示される画面（HomeScreen）
      home: const HomeScreen(),
    );
  }
}

// ホーム画面（メニュー画面）を表すクラス
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面上部のバー（タイトルなどを表示）
      appBar: AppBar(title: const Text('学習支援アプリ')),
      // 画面のメイン部分（body）
      body: Center(
        // 最大幅を420pxに制限（スマホでも見やすくするため）
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            // 子ウィジェット（ボタンやテキスト）を中央に配置
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 「メニュー」というタイトル文字
              const Text(
                'メニュー',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24), // 空白（高さ24）
              // --- ポモドーロ・テクニックボタン ---
              SizedBox(
                width: double.infinity, // ボタンを画面幅いっぱいに広げる
                child: FilledButton(
                  // ボタンを押したときの処理
                  // Navigator.push() で別の画面（PomodoroScreen）に移動
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PomodoroScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    // ボタンに表示する文字
                    child: Text('ポモドーロ・テクニック（Pomodoro Technique）'),
                  ),
                ),
              ),

              const SizedBox(height: 12), // ボタンの間に空白を入れる
              // --- 類題生成ボタン ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  // 類題生成ボタンを押したときの処理
                  // SimilarProblemScreen画面へ移動
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SimilarProblemScreen(),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('類題生成'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
