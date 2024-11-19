import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_app/services/event.dart';
import 'package:study_app/services/goal_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

import 'package:study_app/models/event.dart';

class GoalCard extends StatefulWidget {
  int todayGoalTime;
  int weekGoalTime;
  final int todayStudyTime;
  final int weekStudyTime;
  bool isHiddenEditBtn = false;
  final Function(int, int) onEditGoal;

  GoalCard({
    required this.todayGoalTime,
    required this.weekGoalTime,
    required this.todayStudyTime,
    required this.weekStudyTime,
    required this.onEditGoal,
    this.isHiddenEditBtn = false,
  });

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  int _selectedTodayGoal = 0;
  int _selectedWeekGoal = 0;
  bool _todayGoalError = false;
  bool _weekGoalError = false;

  @override
  void initState() {
    super.initState();
    _selectedTodayGoal = widget.todayGoalTime ~/ 60; // 分から時間へ変換
    _selectedWeekGoal = widget.weekGoalTime ~/ 60; // 分から時間へ変換
  }

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
                    Row(
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
                        if (!widget.isHiddenEditBtn) ...[
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              height: 35,
                              width: 105,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: primary),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showEditGoalDialog(context);
                                },
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(
                                        "目標を変更",
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Icon(Icons.navigate_next, color: primary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 70,
                        ),
                        Expanded(
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
                          child: Text(
                            '今週',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTimeRow(
                          '目標時間',
                          _formatTime(widget.todayGoalTime),
                          _formatTime(widget.weekGoalTime),
                          Colors.blue[100]!,
                        ),
                        SizedBox(height: 8),
                        _buildTimeRow(
                          '学習時間',
                          _formatTime(widget.todayStudyTime),
                          _formatTime(widget.weekStudyTime),
                          Colors.green[100]!,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 70,
                        ),
                        Expanded(
                          child: _buildCircularProgress(
                            widget.todayGoalTime == 0
                                ? 0
                                : widget.todayStudyTime / widget.todayGoalTime,
                          ),
                        ),
                        Expanded(
                          child: _buildCircularProgress(
                            widget.weekGoalTime == 0
                                ? 0
                                : widget.weekStudyTime / widget.weekGoalTime,
                          ),
                        ),
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
          Expanded(
            child: Text(
              todayTime,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
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

  Widget _buildCircularProgress(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
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

  String _formatTime(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  void _showEditGoalDialog(BuildContext context) {
    int tempTodayGoal = _selectedTodayGoal;
    int tempWeekGoal = _selectedWeekGoal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
                  decoration: BoxDecoration(
                    color: subTheme,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '目標を変更',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 今日の目標時間
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('今日の目標時間（時間）'),
                ),
                Container(
                  height: 100,
                  child: CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: tempTodayGoal),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        tempTodayGoal = value;
                        if (tempTodayGoal <= 0) {
                          _todayGoalError = true;
                        } else {
                          _todayGoalError = false;
                        }
                      });
                    },
                    children: List<Widget>.generate(25, (int index) {
                      return Center(
                        child: Text('$index 時間'),
                      );
                    }),
                  ),
                ),
                if (_todayGoalError)
                  Text(
                    '1時間以上を選択してください',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                // 今週の目標時間
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('今週の目標時間（時間）'),
                ),
                Container(
                  height: 100,
                  child: CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: tempWeekGoal),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        tempWeekGoal = value;
                        if (tempWeekGoal <= 0) {
                          _weekGoalError = true;
                        } else {
                          _weekGoalError = false;
                        }
                      });
                    },
                    children: List<Widget>.generate(101, (int index) {
                      return Center(
                        child: Text('$index 時間'),
                      );
                    }),
                  ),
                ),
                if (_weekGoalError)
                  Text(
                    '1時間以上を選択してください',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('キャンセル',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Container(
                height: 35,
                width: 100,
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: subTheme,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: subTheme),
                ),
                child: InkWell(
                  onTap: () async {
                    // バリデーションチェック
                    if (tempTodayGoal <= 0) {
                      setState(() {
                        _todayGoalError = true;
                      });
                      return;
                    }
                    if (tempWeekGoal <= 0) {
                      setState(() {
                        _weekGoalError = true;
                      });
                      return;
                    }

                    // 値が変更されたかチェック
                    if (tempTodayGoal != _selectedTodayGoal ||
                        tempWeekGoal != _selectedWeekGoal) {
                      // データベースに保存
                      int newTodayGoalMinutes = tempTodayGoal * 60;
                      int newWeekGoalMinutes = tempWeekGoal * 60;

                      // 保存処理を実行
                      await _saveGoalTimes(
                          newTodayGoalMinutes, newWeekGoalMinutes);

                      // 状態を更新
                      setState(() {
                        _selectedTodayGoal = tempTodayGoal;
                        _selectedWeekGoal = tempWeekGoal;
                        widget.todayGoalTime = newTodayGoalMinutes;
                        widget.weekGoalTime = newWeekGoalMinutes;
                      });

                      // 親ウィジェットへ新しい目標時間を渡す
                      widget.onEditGoal(
                          newTodayGoalMinutes, newWeekGoalMinutes);
                    }

                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      "保存",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _saveGoalTimes(int todayGoal, int weekGoal) async {
    try {
      // Firestoreのインスタンスを取得
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 現在のユーザーIDを取得
      UserService userService = UserService();
      String? userId = await userService.getCurrentUserId();
      if (userId == null) {
        throw Exception('ユーザーIDの取得に失敗しました。');
      }

      // WeeklyGoal の goalId を取得
      String? weeklyGoalId =
          await GoalService().getWeeklyGoalIdByUserId(userId);
      if (weeklyGoalId == null) {
        throw Exception('WeeklyGoal の goalId の取得に失敗しました。');
      }

      // UserDailyGoals の goalId を取得
      String? dailyGoalId = await GoalService().getDailyGoalIdByUserId(userId);
      if (dailyGoalId == null) {
        throw Exception('UserDailyGoals の goalId の取得に失敗しました。');
      }

      // WeeklyGoal の targetStudyTime を更新
      await firestore.collection('WeeklyGoal').doc(weeklyGoalId).update({
        'targetStudyTime': weekGoal,
      });

      // UserDailyGoals の targetStudyTime を更新
      await firestore.collection('UserDailyGoals').doc(dailyGoalId).update({
        'targetStudyTime': todayGoal,
      });

      print('目標時間が正常に更新されました。');
    } catch (e) {
      print('Firestore 更新中にエラーが発生しました: $e');
      rethrow;
    }
  }
}
