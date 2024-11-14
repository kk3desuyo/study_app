import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/study_card.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/user/app_bar.dart';
import 'package:study_app/widgets/user/stacked_graph.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/widgets/user/tab_bar.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/user/goal.dart';
import 'package:study_app/widgets/preview_detail.dart/week_chart.dart';
import 'package:study_app/widgets/user/study_card.dart';
import 'package:study_app/widgets/user/user_study_summary_card.dart';
import 'package:study_app/widgets/user/icon.dart';
import 'package:study_app/screens/followed_and_following.dart';
import 'package:study_app/screens/profile_edit.dart';
import 'package:study_app/screens/other_user_display_book.dart';

class MyAccountCard extends StatefulWidget {
  final User user;
  final int studyTime;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final List<Tag> tags;
  bool isFollow;
  final int followNum;
  int followersNum;
  final List<Map<String, double>> weeklyStudyTimes;
  final List<Book> books;
  final int todayStudyTime;
  final int weekStudyTime;
  final int todayGoalTime;
  final int weekGoalTime;
  final Function() onChanged;
  final List<StudyCardData> studySessions;

  MyAccountCard({
    Key? key,
    required this.onChanged,
    required this.user,
    required this.studyTime,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
    required this.tags,
    required this.isFollow,
    required this.followNum,
    required this.followersNum,
    required this.weeklyStudyTimes,
    required this.books,
    required this.todayStudyTime,
    required this.weekStudyTime,
    required this.todayGoalTime,
    required this.weekGoalTime,
    required this.studySessions,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAccountCardState();
}

class _MyAccountCardState extends State<MyAccountCard> {
  List<Map<String, Color>> colorList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setColorList();
  }

  void setColorList() {
    List<Map<String, Color>> colorListTmp = [];
    List<Color> availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      primary,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.teal,
      Colors.indigo,
      Colors.lime,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.amber,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.deepPurple,
      Colors.blueGrey,
    ];
    if (widget.weeklyStudyTimes.isEmpty) return;
    int j_tmp = 0;
    for (int i = 0; i < widget.weeklyStudyTimes.length; i++) {
      for (String key in widget.weeklyStudyTimes[i].keys) {
        j_tmp++;
        colorListTmp
            .add({key: availableColors[j_tmp % availableColors.length]});
      }
    }
    setState(() {
      colorList = colorListTmp;
    });
  }

  void _onEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileEditPage(
                user: widget.user,
                tags: widget.tags,
                onChanged: widget.onChanged,
              )),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _onRefresh() async {
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.only(top: 15, left: 6),
              child: Column(
                children: [
                  // ユーザー情報とアイコン
                  Row(
                    children: [
                      UserIcon(
                        profileImgUrl: widget.user.profileImgUrl,
                        onTap: () {
                          // アイコンがタップされたときの処理
                        },
                      ),
                      Spacer(),
                      // フォロー中
                      Expanded(
                        child: InkWell(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowedAndFollowing(
                                  onChanged: widget.onChanged,
                                  userId: widget.user.id,
                                  userName: widget.user.name,
                                  initalSelectedIndex: 0,
                                ),
                              ),
                            )
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("フォロー中",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(width: 4),
                              Text(
                                widget.followNum.toString(),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // フォロワー
                      Expanded(
                        child: InkWell(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowedAndFollowing(
                                    onChanged: widget.onChanged,
                                    userId: widget.user.id,
                                    userName: widget.user.name,
                                    initalSelectedIndex: 1,
                                  ),
                                ))
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("フォロワー",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(width: 4),
                              Text(widget.followersNum.toString(),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // タグ
                  TagsWidget(tags: widget.tags),
                  // 一言
                  Padding(
                      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            // テキストが長い場合に折り返すためにExpandedを追加
                            child: Text(
                              widget.oneWord,
                              style: TextStyle(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      )),
                  // プロフィール編集ボタン
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            height: 35,
                            width: 160,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: subTheme),
                            ),
                            child: InkWell(
                              onTap: _onEditProfile,
                              child: Center(
                                child: Text(
                                  "プロフィールを編集",
                                  style: TextStyle(
                                    color: subTheme,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // 区切り線
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  // タブバー
                  MyTabBar(
                    selectedIndex: _selectedIndex,
                    onTabSelected: _onTabSelected,
                  ),
                  // タブの内容
                  if (_selectedIndex == 0) ...[
                    UserStudySummaryCard(userId: widget.user.id),
                    // タブ1のコンテンツ
                    GoalCard(
                      todayStudyTime: widget.todayStudyTime,
                      weekStudyTime: widget.weekStudyTime,
                      todayGoalTime: widget.todayGoalTime,
                      weekGoalTime: widget.weekGoalTime,
                    ),
                    // 一週間の推移チャート
                    Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: subTheme,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      '一週間の推移',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              StudyTimeBarChart(
                                studyTimes: widget.weeklyStudyTimes,
                                subjects: colorList,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 教材の表示
                    InkWell(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserBookShelf(
                              bookInfos: {
                                for (int i = 0; i < widget.books.length; i++)
                                  i: widget.books[i],
                              },
                            ),
                          ),
                        )
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Card(
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 27),
                                      decoration: BoxDecoration(
                                        color: subTheme,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '教材',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                if (widget.books.length == 0) ...[
                                  SizedBox(
                                    height: 50,
                                  ),
                                  SizedBox(
                                    child: Text("教材がありません"),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  )
                                ],
                                SizedBox(height: 5),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: widget.books.map((book) {
                                      return BookCard(
                                        isTapDisabled: true,
                                        isDisplayTime: false,
                                        book: book,
                                        studyTime: 0, // 必要に応じて値を調整
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (_selectedIndex == 1) ...[
                    // タブ2のコンテンツ
                    Column(
                      children: widget.studySessions.map((session) {
                        return StudyCard(
                          id: session.id,
                          timeStamp: session.timeStamp,
                          studyTime: session.studyTime,
                          memo: session.memo,
                          user: session.user,
                          book: session.book,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            color: Colors.white,
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            elevation: 8,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
