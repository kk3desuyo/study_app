import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_app/models/app/app_setting.dart';
import 'package:study_app/services/daily_goal_service.dart';
import 'package:study_app/services/user/app/app_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:study_app/widgets/home/event.dart';
import 'package:study_app/widgets/home/goal_calender.dart';
import 'package:study_app/widgets/home/rank_card.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/home/study_time_display.dart';
import 'package:study_app/widgets/home/tab_bar.dart';
import 'package:study_app/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDataLoaded = false;
  List<Map<String, dynamic>> followedUserStudySummary = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DailyGoalService dailyGoalService = DailyGoalService();
      List<Map<String, dynamic>> fetchedGoals =
          await dailyGoalService.getFollowedUserDailyGoals();

      setState(() {
        followedUserStudySummary = fetchedGoals;
        _isDataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isDataLoaded = false;
      });
      print('データの取得に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const MyAppBar(),
        backgroundColor: backGroundColor,
        body: Column(
          children: [
            MyTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _home(),
                  _timeLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeLine() {
    return StreamBuilder<DocumentSnapshot>(
      stream: AppService().getAppSettingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: primary,
              size: 80,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          AppSettings appSettings = AppSettings.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);
          print(appSettings.isStudyTimeVisible);

          // タイムラインのデータに基づいてウィジェットを返す
          return ListView(
            children: followedUserStudySummary.map((goal) {
              print(goal['dailyGoalId' + "aaaaa"]);
              return StudySummaryCard(
                dailyGoalId: goal['dailyGoalId'] ?? '',
                user: User(
                  id: goal['user']['id'] ?? '',
                  name: goal['user']['name'] ?? '',
                  profileImgUrl: goal['user']['profileImgUrl'] ?? '',
                ),
                studyTime: goal['achievedStudyTime'] ?? 0,
                goodNum: goal['goodNum'] ?? 0,
                isPushFavorite: goal['isPushFavorite'] ?? false,
                commentNum: goal['commentNum'] ?? 0,
                achivementLevel:
                    (goal['targetStudyTime'] / goal['achievedStudyTime'])
                                .toInt() *
                            100 ??
                        0,
                oneWord: goal['oneWord'] ?? '',
              );
            }).toList(),
          );
        } else {
          return Center(child: Text('データがありません'));
        }
      },
    );
  }

  Widget _home() {
    return SingleChildScrollView(
      child: Column(
        children: [
          RankCard(rank: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: StudyTimeDisplay(studyTime: 200)),
              Expanded(child: EventDisplay(daysLeft: 10, eventName: "TOEIC")),
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
      ),
    );
  }
}
