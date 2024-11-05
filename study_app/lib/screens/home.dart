import 'package:flutter/material.dart';
import 'package:study_app/models/app/app_setting.dart';
import 'package:study_app/services/event.dart';
import 'package:study_app/services/user/app/app_service.dart';
import 'package:study_app/services/user_daily_achievements.dart';
import 'package:study_app/services/daily_goal_service.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:study_app/models/user.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/home/event.dart';
import 'package:study_app/widgets/home/goal_calender.dart';
import 'package:study_app/widgets/home/rank_card.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/home/study_time_display.dart';
import 'package:study_app/widgets/home/tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDataLoaded = false;
  List<Map<String, dynamic>> followedUserStudySummary = [];
  String eventName = "-----";
  List<DateTime> achievements = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isDataLoaded = false; // データ取得開始前にフラグをfalseに設定
    });
    try {
      DailyGoalService dailyGoalService = DailyGoalService();
      List<Map<String, dynamic>> fetchedGoals =
          await dailyGoalService.getFollowedUserDailyGoals();

      setState(() {
        followedUserStudySummary = fetchedGoals;
        _isDataLoaded = true; // データ取得後にフラグをtrueに設定
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
    return RefreshIndicator(
      onRefresh: _fetchData, // 引っ張って更新時にデータを再取得
      child: _isDataLoaded
          ? ListView(
              children: followedUserStudySummary.map((goal) {
                // ゼロ除算を防ぐためにチェックを追加
                int achievementLevel = 0;
                if (goal['targetStudyTime'] != null &&
                    goal['targetStudyTime'] != 0) {
                  achievementLevel =
                      ((goal['achievedStudyTime'] / goal['targetStudyTime']) *
                              100)
                          .toInt();
                }

                return StudySummaryCard(
                  dailyGoalId: goal['dailyGoalId'] ?? '',
                  user: User(
                    oneWord: goal['user']['oneWord'] ?? '',
                    id: goal['user']['id'] ?? '',
                    name: goal['user']['name'] ?? '',
                    profileImgUrl: goal['user']['profileImgUrl'] ?? '',
                  ),
                  studyTime: goal['achievedStudyTime'] ?? 0,
                  goodNum: goal['goodNum'] ?? 0,
                  isPushFavorite: goal['isPushFavorite'] ?? false,
                  commentNum: goal['commentNum'] ?? 0,
                  achivementLevel: achievementLevel,
                  oneWord: goal['oneWord'] ?? '',
                );
              }).toList(),
            )
          : Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: primary,
                size: 80,
              ),
            ),
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
              StreamBuilder<String>(
                stream: EventService().getUserEventNameStream(),
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
                  return Expanded(
                    child: EventDisplay(
                      daysLeft: 10,
                      eventName: snapshot.data ?? "----",
                    ),
                  );
                },
              ),
            ],
          ),
          StreamBuilder<List<DateTime>>(
            stream: UserDailyAchievementsService().getAchievementDatesStream(),
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
              return GoalCalender(
                achievedDates: snapshot.data ?? [],
              );
            },
          ),
        ],
      ),
    );
  }
}
