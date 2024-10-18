import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:study_app/widgets/home/event.dart';
import 'package:study_app/widgets/home/goal_calender.dart';
import 'package:study_app/widgets/home/rank_card.dart';
import 'package:study_app/widgets/home/study_summary_card.dart.dart';
import 'package:study_app/widgets/home/study_time_display.dart';
import 'package:study_app/widgets/home/tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDataLoaded = true; // データベースからの読み込み完了フラグ
  int _selectedIndex = 0; // 現在の選択されているタブのインデックス
  bool isStudyTimePublic = false;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final testUrl =
      "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(),
        backgroundColor: backGroundColor,
        body: isStudyTimePublic
            ? Stack(
                children: [
                  // データが読み込まれている場合のリスト
                  if (_isDataLoaded) ...[
                    ListView(
                      children: [
                        const SizedBox(height: 60), // TabBarの高さ分スペースを確保
                        StudySummaryCard(
                            profileImgUrl: testUrl,
                            name: "ss",
                            studyTime: 370,
                            goodNum: 10,
                            isPushFavorite: true,
                            commentNum: 10,
                            achivementLevel: 100,
                            oneWord: "がんばった",
                            userId: "jo"),
                        StudySummaryCard(
                            profileImgUrl: testUrl,
                            name: "ssd",
                            studyTime: 370,
                            goodNum: 10,
                            isPushFavorite: true,
                            commentNum: 10,
                            achivementLevel: 100,
                            oneWord: "がんばった",
                            userId: "jo"),
                        StudySummaryCard(
                            profileImgUrl: testUrl,
                            name: "上達",
                            studyTime: 370,
                            goodNum: 10,
                            isPushFavorite: true,
                            commentNum: 10,
                            achivementLevel: 100,
                            oneWord: "がんばった",
                            userId: "jo"),
                        StudySummaryCard(
                            profileImgUrl: testUrl,
                            name: "上達",
                            studyTime: 370,
                            goodNum: 10,
                            isPushFavorite: true,
                            commentNum: 10,
                            achivementLevel: 100,
                            oneWord: "がんばった",
                            userId: "jo"),
                      ],
                    ),
                  ] else ...[
                    // 読み込み中のローディング表示
                    Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: primary,
                        size: 80,
                      ),
                    ),
                  ],
                  // TabBarを上に重ねる
                  Positioned(
                    top: 0, // 上部に配置
                    left: 0,
                    right: 0,
                    child: MyTabBar(
                      selectedIndex: _selectedIndex,
                      onTabSelected: _onTabSelected,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 背景色を白に設定
                        side: BorderSide(color: subTheme), // ボーダーの色をsubThemeに設定
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // ボーダーの角を丸くする
                        ),
                        minimumSize: Size(double.infinity, 50), // 横いっぱいに広げる
                        fixedSize: Size(double.infinity, 20), // 高さを60に固定
                      ),
                      onPressed: () {
                        // ボタンが押されたときの処理をここに記述
                        print("昨日の勉強記録を表示");
                      },
                      child: Text(
                        "昨日の勉強記録を表示",
                        style: TextStyle(
                            color: subTheme,
                            fontWeight: FontWeight.bold), // 文字色をsubThemeに設定
                      ),
                    ),
                  ),
                  RankCard(rank: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StudyTimeDisplay(
                        studyTime: 200,
                      ),
                      EventDisplay(
                        daysLeft: 10,
                        eventName: "TOEIC",
                      )
                    ],
                  ),
                  GoalCalender(
                    achievedDates: [
                      DateTime.now().subtract(Duration(days: 3)),
                      DateTime.now().subtract(Duration(days: 0)),
                      DateTime.now().subtract(Duration(days: 1)),
                      DateTime.now().subtract(Duration(days: 2)),
                      DateTime.now().subtract(Duration(days: 4)),
                    ],
                  ),
                ],
              ));
  }
}
