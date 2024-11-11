// lib/widgets/user_study_summary_card.dart

import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:study_app/theme/color.dart';

class UserStudySummaryCard extends StatelessWidget {
  final String userId;

  const UserStudySummaryCard({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("userIDdddd");
    final UserService userService = UserService();
    print(userId);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: userService.getUserDailyGoals(userId), // userIdを指定してデータを取得
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // データ取得中はローディングインジケーターを表示
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: primary,
              size: 50,
            ),
          );
        }

        if (snapshot.hasError) {
          // エラーが発生した場合はエラーメッセージを表示
          return Center(
            child: Text('エラーが発生しました: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // データが存在しない場合の表示
          return Center(
            child: Text('データが存在しません。'),
          );
        }

        // データが取得できた場合はStudySummaryCardを表示
        List<Map<String, dynamic>> studySummaries = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: studySummaries.length,
          itemBuilder: (context, index) {
            final goal = studySummaries[index];

            // ゼロ除算を防ぐためにチェックを追加
            int achievementLevel = 0;
            if (goal['targetStudyTime'] != null &&
                goal['targetStudyTime'] != 0) {
              achievementLevel =
                  ((goal['achievedStudyTime'] / goal['targetStudyTime']) * 100)
                      .toInt();
            }

            // Userオブジェクトの作成
            User user = User(
              isPublic: goal['user']['isPublic'] ?? false,
              oneWord: goal['user']['oneWord'] ?? '',
              id: goal['user']['id'] ?? '',
              name: goal['user']['name'] ?? '',
              profileImgUrl: goal['user']['profileImgUrl'] ?? '',
            );

            // Print all the contents of the user object
            print('User: ${user.toString()}');
            print('Goal: ${goal.toString()}');

            return StudySummaryCard(
              dailyGoalId: goal['dailyGoalId'] ?? '',
              user: user,
              studyTime: goal['achievedStudyTime'] ?? 0,
              goodNum: goal['goodNum'] ?? 0,
              isPushFavorite: goal['isPushFavorite'] ?? false,
              commentNum: goal['commentNum'] ?? 0,
              achivementLevel: achievementLevel,
              oneWord: goal['oneWord'] ?? '',
            );
          },
        );
      },
    );
  }
}
