import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/time/circular_countdown_timer.dart';
import 'package:study_app/widgets/time/tab_bar.dart';
import 'package:study_app/widgets/time/record.dart';
import 'package:study_app/models/book.dart'; // 必要に応じてパスを調整してください
import 'package:study_app/services/book_service.dart'; // BookServiceをインポート

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
  Map<int, Book> bookInfos = {}; // 本の情報を格納するマップ
  bool isLoading = true; // ローディング状態を管理するフラグ

  @override
  void initState() {
    super.initState();
    fetchBookInfos(); // 本の情報を取得するメソッドを呼び出す
  }

  Future<void> fetchBookInfos() async {
    print("fetchBookInfos");
    BookService bookService = BookService();
    try {
      // ユーザーIDを指定して本の情報を取得
      List<Map<String, dynamic>> fetchedBooks =
          await bookService.fetchUserBookDetails((await UserService()
              .getCurrentUserId())!); // 'userId'を適切なユーザーIDに置き換えてください
      print("`fetchedBooks");
      print(fetchedBooks[0]);
      setState(() {
        // 取得した本の情報をマップに変換して格納
        bookInfos = {
          for (var i = 0; i < fetchedBooks.length; i++)
            i: Book.fromFirestore({
              ...fetchedBooks[i],
              'lastUsedDate': (fetchedBooks[i]['lastUsedDate'] as DateTime)
                  .toIso8601String(), // DateTimeをStringに変換
            }),
        };
        print("object");
        print(Book.fromFirestore({
          ...fetchedBooks[0],
          'lastUsedDate': (fetchedBooks[0]['lastUsedDate'] as DateTime)
              .toIso8601String(), // DateTimeをStringに変換
        }).id);
        isLoading = false; // ローディング状態を解除
      });
    } catch (e) {
      print('Error fetching book infos: $e');
      setState(() {
        isLoading = false; // エラーが発生した場合もローディング状態を解除
      });
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ローディング中はインジケーターを表示
          : Padding(
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
                          bookInfos: bookInfos, // データベースから取得した本の情報を渡す
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
