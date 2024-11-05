import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class GoalCard extends StatelessWidget {
  final int todayGoalTime;
  final int weekGoalTime;
  final int todayStudyTime;
  final int weekStudyTime;

  GoalCard({
    required this.todayGoalTime,
    required this.weekGoalTime,
    required this.todayStudyTime,
    required this.weekStudyTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backGroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.only(top: 5, left: 2, right: 2, bottom: 2),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 27),
                      decoration: BoxDecoration(
                        color: subTheme,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '目標',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // 今日、今週のタイトルを横幅に合わせて配置
                    Row(
                      children: [
                        Spacer(flex: 3), // 左側のスペース
                        Expanded(
                          flex: 3,
                          child: Text(
                            '今日',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '今週',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(flex: 2), // 右側のスペース
                      ],
                    ),
                    SizedBox(height: 10),
                    // 目標時間と学習時間を表示（今日と今週の行を並べる）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTimeRow(
                          '目標時間',
                          _formatTime(todayGoalTime),
                          _formatTime(weekGoalTime),
                          Colors.blue[100]!,
                        ),
                        SizedBox(height: 8),
                        _buildTimeRow(
                          '学習時間',
                          _formatTime(todayStudyTime),
                          _formatTime(weekStudyTime),
                          Colors.green[100]!,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // 達成率の円グラフ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularProgress(todayGoalTime == 0
                            ? 0
                            : todayStudyTime / todayGoalTime),
                        _buildCircularProgress(weekGoalTime == 0
                            ? 0
                            : weekStudyTime / weekGoalTime),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 目標時間と学習時間の行を作成する
  Widget _buildTimeRow(
      String label, String todayTime, String weekTime, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(
            width: 60,
            child: Text(
              todayTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Spacer(flex: 1), // todayTimeとweekTimeの間のスペースを広くする
          SizedBox(
            width: 60,
            child: Text(
              weekTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 達成率の円グラフを作成する
  Widget _buildCircularProgress(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(subTheme),
            strokeWidth: 8,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 時間をhh:mm形式に変換するヘルパー関数
  String _formatTime(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }
}
