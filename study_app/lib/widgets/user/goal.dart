import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class GoalCard extends StatelessWidget {
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
              // Padding added around the '目標' section

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // 影のオフセット
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
                          color: Colors.orange,
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

                      // 今日、今週、今月のタイトルをまとめて表示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 9,
                          ),
                          Text(
                            '今日',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '今週',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '今月',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // 目標時間と学習時間を表示
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 目標時間
                          _buildTimeRow(
                            '目標時間',
                            '02:00',
                            '10:00',
                            '50:00',
                            Colors.blue[100]!,
                          ),

                          // 学習時間
                          _buildTimeRow(
                            '学習時間',
                            '04:10',
                            '09:45',
                            '35:23',
                            Colors.green[100]!,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // 達成率の円グラフ
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // 隙間を均等に
                        children: [
                          SizedBox(width: 45),
                          _buildCircularProgress(0.75),
                          _buildCircularProgress(0.75),
                          _buildCircularProgress(0.75),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // 目標時間と学習時間の行を作成する
  Widget _buildTimeRow(String label, String todayTime, String weekTime,
      String monthTime, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 16), // ラベルと値の間の隙間を調整
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 均等に配置
              children: [
                Text(todayTime),
                Text(weekTime),
                Text(monthTime),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  // 達成率の円グラフを作成する
  Widget _buildCircularProgress(double progress) {
    return Stack(
      alignment: Alignment.center, // 中央に配置
      children: [
        SizedBox(
          height: 70, // 円のサイズを指定
          width: 70,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300], // 未達成部分の色を設定
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange), // 達成部分の色
            strokeWidth: 8,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%', // 円の中にパーセンテージを表示
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: GoalCard()))));
}
