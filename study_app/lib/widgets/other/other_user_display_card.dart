import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/tag_modale.dart';
import 'package:study_app/screens/followed_and_following.dart';
import 'package:study_app/screens/other_user_display_book.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/follow_button.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/user/goal.dart';
import 'package:study_app/widgets/user/stacked_graph.dart';
import 'package:study_app/widgets/user/tab_bar.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/widgets/user/user_study_summary_card.dart';

class OtherUserDisplayCard extends StatefulWidget {
  final User user;
  final int studyTime;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final List<double> studyTimes;
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
  OtherUserDisplayCard({
    Key? key,
    required this.onChanged,
    required this.user,
    required this.studyTimes,
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
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OtherUserDisplayCardState();
}

class _OtherUserDisplayCardState extends State<OtherUserDisplayCard> {
  List<Map<String, Color>> colorList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setColorList();
  }

  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}時間${minutes}分';
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
    print("colorListTmp");
    print(colorListTmp);
    setState(() {
      colorList = colorListTmp;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("books");
    for (var book in widget.books) {
      print(book.id);
      print(book.category);
      print(book.title);
    }
    print("tags");
    print(widget.user.id);
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Card(
                child: Padding(
                    padding: EdgeInsets.only(top: 15, left: 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (widget.user.profileImgUrl.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, bottom: 3, right: 20),
                                child: Container(
                                  width: 42.0,
                                  height: 42.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(21.0),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          widget.user.profileImgUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4, bottom: 3, right: 3),
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50.0,
                                ),
                              ),
                            Spacer(),
                            Expanded(
                              child: InkWell(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FollowedAndFollowing(
                                        userId: widget.user.id,
                                        userName: widget.user.name,
                                        initalSelectedIndex: 0,
                                        onChanged: widget.onChanged,
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
                            Expanded(
                              child: InkWell(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FollowedAndFollowing(
                                        userId: widget.user.id,
                                        userName: widget.user.name,
                                        initalSelectedIndex: 1,
                                        onChanged: widget.onChanged,
                                      ),
                                    ),
                                  )
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
                        TagsWidget(tags: widget.tags),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DefaultTextStyle(
                                  style: TextStyle(color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  child: Text(widget.oneWord),
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 30, top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FollowButton(
                                followingUserId: widget.user.id,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
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
                        MyTabBar(
                          selectedIndex: _selectedIndex,
                          onTabSelected: _onTabSelected,
                        ),
                        if (_selectedIndex == 0) ...[
                          GoalCard(
                            onEditGoal: (int a, int b) {},
                            isHiddenEditBtn: true,
                            todayStudyTime: widget.todayStudyTime,
                            weekStudyTime: widget.weekStudyTime,
                            todayGoalTime: widget.todayGoalTime,
                            weekGoalTime: widget.weekGoalTime,
                          ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: subTheme,
                                            borderRadius:
                                                BorderRadius.circular(15),
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
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserBookShelf(
                                    bookInfos: {
                                      for (int i = 0;
                                          i < widget.books.length;
                                          i++)
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: widget.books.map((book) {
                                          return BookCard(
                                            isDisplayTime: false,
                                            book: book,
                                            studyTime:
                                                300, // Adjust this value as needed
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Column(
                            children: [
                              UserStudySummaryCard(userId: widget.user.id)
                            ],
                          ),
                        ]
                      ],
                    )),
                color: Colors.white,
                margin: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 10),
                elevation: 8,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
