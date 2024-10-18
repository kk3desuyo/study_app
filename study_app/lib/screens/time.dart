import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/time/circular_countdown_timer.dart';
import 'package:study_app/widgets/time/tab_bar.dart';
import 'package:study_app/widgets/user/book_shelf.dart';
import 'package:study_app/widgets/time/record.dart';

class TimePage extends StatefulWidget {
  const TimePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimePage();
}

class _TimePage extends State<TimePage> {
  // studyTimeを状態として定義
  int studyTime = 0;
  int selectedTab = 0;
  bool isChangeTime = false;

  void onChangedTime() {
    setState(() {
      isChangeTime = true;
    });
    print("onChangedTime");
    print(isChangeTime);
  }

  void onTabSelected(int newTabSelect) {
    setState(() {
      selectedTab = newTabSelect;
    });
  }

  // studyTimeを更新するためのコールバック関数
  void updateStudyTime(int newStudyTime) {
    setState(() {
      studyTime = newStudyTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(),
      body: SingleChildScrollView(
        // スクロールを可能にする
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              if (!isChangeTime)
                MyTabBar(
                    isChangeTime: isChangeTime,
                    selectedIndex: selectedTab,
                    onTabSelected: onTabSelected),
              selectedTab == 1
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: 4, right: 8, left: 8, bottom: 30),
                      child: Container(
                        // 丸角を設定
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20), // 角を丸くする
                        ),
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: StopwatchIndicator(
                            backgroundColor: backGroundColor,
                            valueColor: primary,
                            initialTime: studyTime,
                            // 子ウィジェットにコールバックを渡す
                            onTimeChange: updateStudyTime,
                          ),
                        ),
                      ),
                    )
                  : Record(
                      isTimeChange: isChangeTime,
                      onChangedTime: onChangedTime,
                      bookInfos: {
                        1: Book(
                          isRecentlyUse: false,
                          bookImgUrl:
                              'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc1358308.jpg',
                          category: 'Math',
                          name: 'Algebra Basics',
                          id: 1,
                        ),
                        2: Book(
                          isRecentlyUse: true,
                          bookImgUrl:
                              'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc0091358308.jpg',
                          category: 'Science',
                          name: 'Physics Principles',
                          id: 2,
                        ),
                        3: Book(
                          isRecentlyUse: true,
                          bookImgUrl:
                              'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc0091358308.jpg',
                          category: 'Science',
                          name: 'Physics Principles',
                          id: 2,
                        ),
                        4: Book(
                          isRecentlyUse: true,
                          bookImgUrl:
                              'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc0091358308.jpg',
                          category: 'Science',
                          name: 'Physics Principles',
                          id: 2,
                        ),
                        5: Book(
                          isRecentlyUse: true,
                          bookImgUrl:
                              'https://thumbnail.image.rakuten.co.jp/@0_mall/learners/cabinet/08213828/08213829/imgrc0091358308.jpg',
                          category: 'Science',
                          name: 'Physics Principles',
                          id: 2,
                        ),
                      },
                      studyTime: studyTime,
                      // 子ウィジェットにコールバックを渡す
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
