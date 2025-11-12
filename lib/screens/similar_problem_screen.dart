// 画像のバイト列を文字列化（Base64など）するための標準ライブラリ
import 'dart:convert';
// 端末のファイル（File）を扱うための標準ライブラリ
import 'dart:io';
// Flutterの基本UI（ボタンやテキストなど）を使うため
import 'package:flutter/material.dart';
// カメラで写真を撮る／ギャラリーから選ぶためのパッケージ（image_picker）
import 'package:image_picker/image_picker.dart';
// HTTP通信用のパッケージ（API呼び出しに使用）
import 'package:http/http.dart' as http;

/// この画面（Screen）は、撮影した問題画像を OpenAI に送り、
/// 画像のレベル・形式に合わせた「類題（Similar Problems）」を作ってもらう機能です。
class SimilarProblemScreen extends StatefulWidget {
  const SimilarProblemScreen({super.key});

  @override
  State<SimilarProblemScreen> createState() => _SimilarProblemScreenState();
}

// 画面の「状態（State）」を持つクラス（撮影した画像や結果テキストなどを保持）
class _SimilarProblemScreenState extends State<SimilarProblemScreen> {
  // 画像を撮るためのヘルパー（image_picker のインスタンス）
  final ImagePicker _picker = ImagePicker();

  // 撮った画像ファイル（まだ撮っていないときは null）
  File? _takenImage;

  // OpenAI から返ってきたテキスト（問題＋解説）
  String? _resultText;

  // 通信中かどうか（ローディング表示に使う）
  bool _loading = false;

  // エラーメッセージ（失敗時に表示）
  String? _error;

  // カメラを起動して撮影 → OpenAI API に送信 → 結果を画面に表示、という一連の流れ
  Future<void> _takeAndSend() async {
    // 新しく撮るので、前回の結果やエラーをいったん消す
    setState(() {
      _resultText = null;
      _error = null;
    });

    // === 1) カメラ起動 → 撮影 ===
    // pickImage() は非同期（async）で、ユーザーが撮影するまで待つ
    final XFile? shot = await _picker.pickImage(
      source: ImageSource.camera, // カメラを使う（ギャラリーなら ImageSource.gallery）
      imageQuality: 90, // 画質（0〜100）。大きすぎると通信が重くなる
    );
    if (shot == null) return; // キャンセルされた場合は何もしない

    // 撮影した画像のパス（path）から File オブジェクトを作って保存
    setState(() {
      _takenImage = File(shot.path);
    });

    // === 2) 画像を Base64 へ変換（data URL 化） ===
    // API に直接画像ファイルを渡すのではなく、「文字列化」して送る方法
    final bytes = await _takenImage!.readAsBytes(); // 画像をバイト配列に読む
    final b64 = base64Encode(bytes); // Base64 テキストに変換
    // 先頭に「data:image/jpeg;base64,」を付けた data URL 形式にする
    final dataUrl = 'data:image/jpeg;base64,$b64';

    // === 3) OpenAI API を呼び出す ===
    setState(() => _loading = true); // ローディング開始（画面にクルクル表示）
    try {
      // APIキーの取得方法：
      // flutter run のとき --dart-define=OPENAI_API_KEY=xxxxx と渡し、
      // const String.fromEnvironment で受け取る（コードに直書きしないのが安全）
      final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
      if (apiKey.isEmpty) {
        // キーが設定されていない場合は例外にして catch へ
        throw Exception('OPENAI_API_KEY が未設定です（--dart-define で渡してください）。');
      }

      // === API のエンドポイントとヘッダ ===
      // Chat Completions API（Vision 入力に対応したモード）を使う想定
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer $apiKey', // 認証（Bearerトークン）
        'Content-Type': 'application/json', // 送信データは JSON
      };

      // === モデルに渡す指示（プロンプト / Prompt） ===
      // 画像の問題と同じレベル・同じ形式の「新しい1問」を日本語で作ってもらう
      final prompt =
          'この画像にはテストやドリルの「問題」が写っています。'
          '画像の問題の知識レベルと同じレベルであり、同じ形式の問題を1問、日本語で作成してください。'
          '問題と解説してだけを出力してください。';

      // === リクエストボディ（messages に「テキスト＋画像（data URL）」を渡す） ===
      final body = {
        'model': 'gpt-4o-mini', // Vision 対応の最新モデル（必要に応じて更新）
        'messages': [
          {
            'role': 'user',
            'content': [
              // テキストの指示
              {'type': 'text', 'text': prompt},
              // 画像（data URL を "image_url" に渡す）
              {
                'type': 'image_url',
                'image_url': {'url': dataUrl},
              },
            ],
          },
        ],
        'temperature': 0.2, // 出力のランダム性（必要なら調整）
      };

      // === HTTP POST で送信 ===
      final resp = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      // === 4) レスポンスの処理 ===
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // 成功時は JSON をパース（decode）
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = decoded['choices'] as List?;
        String? text;
        if (choices != null && choices.isNotEmpty) {
          // 最初の候補（first choice）から message.content を取る
          final firstChoice = choices.first as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          text = message?['content']?.toString();
        }
        // 画面に結果を表示
        setState(() => _resultText = text ?? '応答本文が取得できませんでした。');
      } else {
        // エラーレスポンスの場合は、ステータスコードと本文を表示
        setState(() => _error = 'APIエラー: ${resp.statusCode}\n${resp.body}');
      }
    } catch (e) {
      // 通信・パース・その他の例外をまとめて表示
      setState(() => _error = '送信に失敗しました: $e');
    } finally {
      // どんな場合でもローディング終了
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面上部のバー（タイトル表示）
      appBar: AppBar(title: const Text('類題生成')),

      // 右下に浮かぶ実行ボタン（FloatingActionButton：撮影→送信）
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _takeAndSend, // 通信中は押せないようにする
        icon: const Icon(Icons.photo_camera),
        label: const Text('撮影して送信'),
      ),

      // 画面のメイン部分
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520), // 最大幅を制限（見やすさ向上）
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              // 縦に長くなってもスクロールできるようにする
              child: Column(
                children: [
                  // 撮影した画像があれば表示、なければ撮影の案内テキスト
                  if (_takenImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12), // 角丸表示
                      child: Image.file(_takenImage!, fit: BoxFit.cover),
                    )
                  else
                    const Text('右下のボタンから問題を撮影してください。'),

                  const SizedBox(height: 16),

                  // 通信中はクルクル（ローディング）を表示
                  if (_loading) const CircularProgressIndicator(),

                  // エラーがあれば赤文字で表示
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],

                  // 結果（類題テキスト）があれば区切り線とともに表示
                  if (_resultText != null) ...[
                    const Divider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '出力（類題）',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // SelectableText：コピーしやすいように、選択できるテキスト
                    SelectableText(_resultText!),
                    const SizedBox(height: 80),
                  ],

                  // 余白（下のFABに被りにくくするためのスペース）
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
