import 'package:flutter/material.dart';
import 'dart:math' as math;

class StopwatchIndicator extends StatefulWidget {
  final Color backgroundColor;
  final Color valueColor;
  final TextStyle? timeTextStyle;
  final int initialTime; // 追加: 初期時間を受け取る
  final Function(int) onTimeChange; // 追加: 時間更新のコールバック
  final Function(bool) changeRunnnigState; // 追加: ストップウォッチのスタート/停止を切り替える関数
  final bool Function() getIsRunning; // 追加: ストップウォッチの状態を取得する関数
  const StopwatchIndicator({
    super.key,
    required this.getIsRunning,
    required this.changeRunnnigState,
    required this.backgroundColor,
    required this.valueColor,
    this.timeTextStyle,
    required this.initialTime, // 追加
    required this.onTimeChange, // 追加
  });

  @override
  State<StopwatchIndicator> createState() => _StopwatchIndicatorState();
}

class _StopwatchIndicatorState extends State<StopwatchIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _loopingCircleController;
  Duration elapsedTime = Duration.zero;

  @override
  void dispose() {
    _animationController.dispose();
    _loopingCircleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 初期時間を秒に変換
    final initialDuration = Duration(seconds: widget.initialTime);

    // ストップウォッチのアニメーション
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3600), // 1時間のタイマー
    )..addListener(() {
        setState(() {
          // 経過時間をアニメーションコントローラーの進行に合わせて更新
          elapsedTime = initialDuration +
              (_animationController.duration! * _animationController.value);
        });
      });

    // 4秒でループするサークルのコントローラー
    _loopingCircleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  // ストップウォッチのスタート/停止を切り替える関数
  void toggleStopwatch() {
    setState(() {
      if (widget.getIsRunning()) {
        _animationController.stop();
        _loopingCircleController.stop(); // サークルも停止
        widget.changeRunnnigState(false);

        // ストップ時に親に時間を通知
        widget.onTimeChange(elapsedTime.inMinutes);
      } else {
        _animationController.forward(from: _animationController.value);
        _loopingCircleController.repeat(); // サークルをループ
        widget.changeRunnnigState(true);
      }
    });
  }

  // 経過時間をフォーマットする関数
  String formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 5秒でループするサークル
              SizedBox(
                height: 280,
                width: 280,
                child: AnimatedBuilder(
                  animation: _loopingCircleController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      strokeWidth: 10,
                      backgroundColor: widget.backgroundColor,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(widget.valueColor),
                      value: _loopingCircleController.value,
                    );
                  },
                ),
              ),
              // ストップウォッチの中央に表示される時間
              Center(
                child: Text(
                  formatElapsedTime(elapsedTime),
                  style: widget.timeTextStyle ??
                      Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          ElevatedButton(
            onPressed: toggleStopwatch,
            child: Text(widget.getIsRunning() ? "一時停止" : "スタート"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 35),
              backgroundColor: widget.getIsRunning() ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
