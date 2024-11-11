import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/services/study_session.dart';
import 'package:study_app/services/goal_service.dart'; // GoalServiceを追加
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/controller_manager.dart';
import 'package:study_app/widgets/other/other_user_display_card.dart';
import 'package:study_app/widgets/other/other_user_private_display_card.dart';
import 'package:study_app/widgets/user/app_bar.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/models/user.dart';

class OtherUserDisplay extends StatefulWidget {
  final User user;

  const OtherUserDisplay({Key? key, required this.user}) : super(key: key);

  @override
  State<OtherUserDisplay> createState() => _OtherUserDisplayState();
}

class _OtherUserDisplayState extends State<OtherUserDisplay> {
  List<Map<String, double>>? studyTimes; // Firestoreから取得したstudyTimesを格納
  bool isLoading = true;
  List<Book> books = [];
  int todayGoalTime = 0;
  int weekGoalTime = 0;
  int weekStudyTime = 0;
  int todayStudyTime = 0;
  int followNum = 0;
  int followersNum = 0;
  bool isFollow = false;
  List<Tag> tags = []; // タグ情報を格納するリスト
  bool isUserFollowing = false;

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void _onChanged() {
    setState(() {
      isLoading = true;
    });
    fetchData();
  }

  // Firestoreからデータを取得する非同期関数
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    UserService userService = UserService(); // UserServiceをインスタンス化

    try {
      // フォロー数とフォロワー数を取得
      int followersCount = await userService.getFollowersCount(widget.user.id);
      int followingCount = await userService.getFollowingCount(widget.user.id);

      // 現在のユーザーがこのユーザーをフォローしているか確認
      isUserFollowing = await userService.isUserFollowing(widget.user.id);

      // 非公開ユーザーの場合　かつ　現在のユーザーがフォローしていないここで処理を終了
      if (!widget.user.isPublic && isUserFollowing == false) {
        setState(() {
          followNum = followingCount;
          followersNum = followersCount;
          isFollow = isUserFollowing;
          isLoading = false;
        });
        return;
      }

      // 以下は公開ユーザーの場合のみ取得
      StudySessionService studySessionService = StudySessionService();
      BookService bookService = BookService();
      GoalService goalService = GoalService(); // GoalServiceをインスタンス化

      // ユーザーIDに基づいて学習時間を取得
      List<Map<String, double>> times =
          await studySessionService.fetchStudyTimes(widget.user.id);

      // ユーザーIDに基づいて教材情報を取得
      List<Map<String, dynamic>> bookDetails =
          await bookService.fetchUserBookDetails(widget.user.id);
      print(bookDetails);
      List<Book> fetchedBooks = bookDetails.map((bookDetail) {
        return Book(
            id: bookDetail['bookId'],
            title: bookDetail['title'],
            imgUrl: bookDetail['imgUrl'],
            category: bookDetail['categoryName'],
            lastUsedDate: DateTime.now());
      }).toList();

      // 今日と今週の目標・達成時間を取得
      var dailyGoalData = await goalService.fetchDailyGoalData(widget.user.id);
      var weeklyGoalTime = await goalService.fetchWeeklyGoal(widget.user.id);
      var weeklySummary =
          await goalService.fetchUserWeeklySummary(widget.user.id);

      // タグ情報を取得
      List<Map<String, dynamic>> userTags =
          await userService.fetchUserTags(widget.user.id);
      List<Tag> fetchedTags = userTags.map((tagData) {
        return Tag(
          name: tagData['name'],
          isAchievement: tagData['isAchievement'],
        );
      }).toList();

      setState(() {
        studyTimes = times;
        books = fetchedBooks;
        todayGoalTime = dailyGoalData?['targetStudyTime'] ?? 0;
        todayStudyTime = dailyGoalData?['achievedStudyTime'] ?? 0;
        weekGoalTime = weeklyGoalTime ?? 0;
        weekStudyTime = weeklySummary ?? 0;
        followNum = followingCount; // フォロー数を格納
        followersNum = followersCount; // フォロワー数を格納
        isFollow = isUserFollowing; // フォロー状態を格納
        tags = fetchedTags; // タグ情報を格納
        isLoading = false;
      });
    } catch (e) {
      print("データの取得中にエラーが発生しました: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: MyAppBarUser(
        userName: widget.user.name,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : widget.user.isPublic || isUserFollowing
              ? OtherUserDisplayCard(
                  onChanged: _onChanged,
                  todayGoalTime: todayGoalTime,
                  weekGoalTime: weekGoalTime,
                  weekStudyTime: weekStudyTime,
                  todayStudyTime: todayStudyTime,
                  books: books,
                  weeklyStudyTimes: studyTimes ?? [],
                  user: widget.user,
                  followNum: followNum,
                  followersNum: followersNum,
                  isFollow: isFollow,
                  studyTime: 370,
                  commentNum: 10,
                  achivementLevel: 100,
                  oneWord: widget.user.oneWord ?? "英単語",
                  studyTimes: [],
                  tags: tags,
                )
              : OtherUserPrivateDisplayCard(
                  user: widget.user,
                  followNum: followNum,
                  followersNum: followersNum,
                ),
    );
  }
}
