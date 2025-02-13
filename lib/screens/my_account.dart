import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/study_card.dart';
import 'package:study_app/models/tag_modale.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/user/tag_service.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/services/study_session.dart';
import 'package:study_app/services/goal_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/my_account_card.dart';
import 'package:study_app/widgets/user/app_bar.dart';
import 'package:study_app/widgets/user/tag.dart';

class MyAccount extends StatefulWidget {
  MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  User? user;
  bool isLoading = true;
  List<StudyCardData> _studyCardDataList = [];
  List<Book> books = [];
  int todayGoalTime = 0;
  int weekGoalTime = 0;
  int weekStudyTime = 0;
  int todayStudyTime = 0;
  int followNum = 0;
  int followersNum = 0;
  bool isFollow = false;
  List<Tag> tags = [];
  List<Map<String, double>>? studyTimes;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    UserService userService = UserService();
    String? userId = userService.getCurrentUserId();

    if (userId != null) {
      User? fetchedUser = await userService.getUser(userId);
      print(fetchedUser!.profileImgUrl);
      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
        });
        await fetchData();
        await fetchStudySessions();
      } else {
        print('ユーザー情報の取得に失敗しました');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('ユーザーIDの取得に失敗しました');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWeeklyGoalData() async {
    final goalService = GoalService();

    // ユーザーIDを指定してデータを取得
    final weeklyGoalData =
        await goalService.fetchWeeklyGoalAndSummary(user!.id);

    if (weeklyGoalData != null) {
      print("Achieved Study Time: ${weeklyGoalData['achievedStudyTime']}");
      print("Target Study Time: ${weeklyGoalData['targetStudyTime']}");
      print("Target Week: ${weeklyGoalData['targetWeek']}");
      print("User ID: ${weeklyGoalData['userId']}");
    } else {
      print("No WeeklyGoal data found for the user.");
    }
  }

  Future<void> fetchData() async {
    if (user == null) return;

    StudySessionService studySessionService = StudySessionService();
    BookService bookService = BookService();
    GoalService goalService = GoalService();
    UserService userService = UserService();

    try {
      List<Map<String, double>> times =
          await studySessionService.fetchStudyTimes(user!.id);
      List<Map<String, dynamic>> bookDetails =
          await bookService.fetchUserBookDetails(user!.id, true);
      List<Book> fetchedBooks = bookDetails.map((bookDetail) {
        return Book(
            categoryId: bookDetail['categoryId'],
            id: bookDetail['bookId'],
            title: bookDetail['title'],
            imgUrl: bookDetail['imgUrl'],
            category: bookDetail['category'],
            lastUsedDate: DateTime.now(),
            isPrivate: bookDetail['isPrivate']);
      }).toList();
      print("fetchUse4r");
      var dailyGoalData = await goalService.fetchDailyGoalData(user!.id);
      print("f---------");
      print("Weekめ");
      // ユーザーIDを指定してデータを取得
      final weeklyGoalData =
          await goalService.fetchWeeklyGoalAndSummary(user!.id);
      print("Week後");
      int followersCount = await userService.getFollowersCount(user!.id);
      int followingCount = await userService.getFollowingCount(user!.id);
      TagService tagService = TagService();
      List<Tag> userTags = await tagService.fetchTagsForUser(user!.id);
      List<Tag> fetchedTags = userTags.map((tagData) {
        return Tag(
          id: tagData.id,
          name: tagData.name,
          isAchievement: tagData.isAchievement,
        );
      }).toList();

      setState(() {
        studyTimes = times;
        books = fetchedBooks;
        todayGoalTime = dailyGoalData?['targetStudyTime'] ?? 0;
        todayStudyTime = dailyGoalData?['achievedStudyTime'] ?? 0;
        weekGoalTime = weeklyGoalData?['targetStudyTime'] ?? 0;
        weekStudyTime = weeklyGoalData?['achievedStudyTime'] ?? 0;
        followNum = followingCount;
        followersNum = followersCount;
        isFollow = false;
        tags = fetchedTags;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStudySessions() async {
    try {
      List<StudyCardData> studyCardDataList =
          await StudySessionService().fetchLast7DaysStudySessions(user!.id);
      print("fetchStudySessions");
      print(studyCardDataList.length);
      setState(() {
        _studyCardDataList = studyCardDataList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching study sessions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchUserData();
    setState(() {
      isLoading = false;
    });
  }

  void _onChanged() {
    setState(() {
      isLoading = true;
    });
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: MyAppBarUser(
        userName: user?.name ?? 'My Account',
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  MyAccountCard(
                    studySessions: _studyCardDataList,
                    onChanged: _onChanged,
                    todayGoalTime: todayGoalTime,
                    weekGoalTime: weekGoalTime,
                    weekStudyTime: weekStudyTime,
                    todayStudyTime: todayStudyTime,
                    books: books,
                    weeklyStudyTimes: studyTimes ?? [],
                    user: user!,
                    followNum: followNum,
                    followersNum: followersNum,
                    isFollow: isFollow,
                    studyTime: 370,
                    commentNum: 10,
                    achivementLevel: 100,
                    oneWord: user?.oneWord ?? '',
                    tags: tags,
                  ),
                ],
              ),
            ),
    );
  }
}
