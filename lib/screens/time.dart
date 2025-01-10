import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/time/circular_countdown_timer.dart';
import 'package:study_app/widgets/time/tab_bar.dart';
import 'package:study_app/widgets/time/record.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void changeRunningState(bool newIsRunning) {
    setState(() {
      isRunning = newIsRunning;
    });
  }

  bool getIsRunning() {
    return isRunning;
  }

  void changeTime(bool newIsChangeTime) {
    setState(() {
      isChangeTime = newIsChangeTime;
    });
    print("changeTime");
    print(isChangeTime);
  }

  void onTabSelected(int newTabSelect) {
    if (newTabSelect == 0 && selectedTab == 1 && isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ストップウォッチを停止してください'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            if (!isChangeTime)
              MyTabBar(
                isChangeTime: isChangeTime,
                selectedIndex: selectedTab,
                onTabSelected: onTabSelected,
              ),
            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: [
                  Record(
                    key: ValueKey(studyTime),
                    isTimeChange: isChangeTime,
                    changeTime: changeTime,
                    studyTime: studyTime,
                  ),
                  StopwatchIndicator(
                    getIsRunning: getIsRunning,
                    changeRunnnigState: changeRunningState,
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
