import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/time/circular_countdown_timer.dart';
import 'package:study_app/widgets/time/tab_bar.dart';
import 'package:study_app/widgets/time/record.dart';
import 'package:study_app/models/book.dart'; // 必要に応じてパスを調整してください

class TimePage extends StatefulWidget {
  const TimePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimePage();
}

class _TimePage extends State<TimePage> {
  int studyTime = 0;
  int selectedTab = 0;
  bool isChangeTime = false;
  bool isRunning = false;

  void changeRunnnigState(bool newIsRunning) {
    setState(() {
      isRunning = newIsRunning;
    });
  }

  bool getIsRunning() {
    return isRunning;
  }

  void chagneTime(bool newIsChangeTime) {
    setState(() {
      isChangeTime = newIsChangeTime;
    });
    print("chagneTime");
    print(isChangeTime);
  }

  void onTabSelected(int newTabSelect) {
    if (newTabSelect == 0 && selectedTab == 1 && isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ストップウォッチを停止してください'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // タイマーが動いている場合はタブを切り替えない
    if (isRunning) return;
    setState(() {
      selectedTab = newTabSelect;
    });
  }

  // studyTimeを更新するためのコールバック関数
  void updateStudyTime(int newStudyTime) {
    print(newStudyTime);
    setState(() {
      studyTime = newStudyTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            if (!isChangeTime)
              MyTabBar(
                  isChangeTime: isChangeTime,
                  selectedIndex: selectedTab,
                  onTabSelected: onTabSelected),
            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: [
                  Record(
                    key: ValueKey(studyTime),
                    isTimeChange: isChangeTime,
                    changeTime: chagneTime,
                    bookInfos: {
                      1: Book(
                        lastUsedDate: DateTime.now(),
                        imageUrl:
                            'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc1358308.jpg',
                        category: 'Math',
                        title: 'Algebra Basics',
                        id: '1',
                      ),
                      // 他の教材情報もここに追加
                    },
                    studyTime: studyTime,
                  ),
                  StopwatchIndicator(
                    getIsRunning: getIsRunning,
                    changeRunnnigState: changeRunnnigState,
                    backgroundColor: backGroundColor,
                    valueColor: primary,
                    initialTime: studyTime,
                    onTimeChange: updateStudyTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
