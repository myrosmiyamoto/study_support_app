// 時間を扱うためのパッケージ（一定時間ごとに処理を繰り返すなど）
import 'dart:async';
// Flutterの基本UI部品を使うためのパッケージ
import 'package:flutter/material.dart';

// ポモドーロタイマー画面（集中タイマー画面）を表すクラス
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  // StatefulWidget（ステートフルウィジェット）は、
  // 「動く・変わる」データを持つ画面を作るときに使う。
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

// 実際のタイマーの状態や動作を管理するクラス
class _PomodoroScreenState extends State<PomodoroScreen> {
  // === 設定値 ===
  // 集中時間と休憩時間を設定（デフォルトでは25分と5分）
  static const int workMinutes = 25;
  static const int breakMinutes = 5;

  // === 状態を表す変数 ===
  int _remainingSeconds = workMinutes * 60; // 残り時間（秒単位）
  bool _isWorking = true; // trueなら「集中中」、falseなら「休憩中」
  Timer? _timer; // タイマーオブジェクト（時間をカウントダウンする）

  // === タイマーをスタートする関数 ===
  void _start() {
    // すでにタイマーが動いていたら、もう一度動かさない
    if (_timer?.isActive == true) return;

    // 1秒ごとに繰り返し実行されるタイマーを作成
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        // 時間が0になったら、集中 ↔ 休憩 を切り替える
        setState(() {
          _isWorking = !_isWorking; // true⇄falseの切り替え
          _remainingSeconds =
              (_isWorking ? workMinutes : breakMinutes) * 60; // 次の時間をセット
        });
      } else {
        // まだ時間が残っている場合は1秒減らす
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  // === 一時停止ボタンを押したときの処理 ===
  void _pause() {
    _timer?.cancel(); // タイマーを止める（再開は_startで）
  }

  // === リセットボタンを押したときの処理 ===
  void _reset() {
    _timer?.cancel(); // タイマーを止める
    setState(() {
      _isWorking = true; // 状態を集中モードに戻す
      _remainingSeconds = workMinutes * 60; // 時間を初期値（25分）に戻す
    });
  }

  // === 秒を「mm:ss」形式に変換する関数 ===
  // 例：125秒 → "02:05"
  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0'); // 分（2桁表示）
    final s = (seconds % 60).toString().padLeft(2, '0'); // 秒（2桁表示）
    return '$m:$s'; // "mm:ss" の形にして返す
  }

  // 画面が閉じられたときに呼ばれる（メモリ解放）
  @override
  void dispose() {
    _timer?.cancel(); // タイマーを止めてリソースを開放
    super.dispose();
  }

  // === 画面を作る部分 ===
  @override
  Widget build(BuildContext context) {
    // 現在の状態に応じて表示する文字を切り替える
    final phaseLabel = _isWorking ? '集中 (Work)' : '休憩 (Break)';

    return Scaffold(
      // 上部バー（タイトル）
      appBar: AppBar(title: const Text('ポモドーロ・タイマー')),
      // メイン画面の中身
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420), // 最大幅を420に制限
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
            children: [
              // 状態表示（集中 or 休憩）
              Text(phaseLabel, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8), // 少し空ける
              // 残り時間を表示（例：24:59）
              Text(
                _format(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 64, // 大きな文字で表示
                  fontFeatures: [FontFeature.tabularFigures()], // 数字の幅を揃える
                ),
              ),

              const SizedBox(height: 24), // ボタンとの間に空白を入れる
              // --- ボタン3つを横に並べる ---
              Wrap(
                spacing: 12, // ボタンの間隔
                children: [
                  // ▶ Start ボタン（FilledButton は塗りつぶしスタイル）
                  FilledButton.icon(
                    onPressed: _start, // ボタンを押したときの処理
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),

                  // ❚❚ Pause ボタン（OutlinedButton は枠線スタイル）
                  OutlinedButton.icon(
                    onPressed: _pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),

                  // ↻ Reset ボタン（TextButton は文字だけのボタン）
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 16), // 下に少し空白を入れる
              // 説明文
              const Text('集中25分→休憩5分を自動で交互に切り替えます。'),
            ],
          ),
        ),
      ),
    );
  }
}
