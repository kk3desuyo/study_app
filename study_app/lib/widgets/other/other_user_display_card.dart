import 'package:flutter/material.dart';
import 'package:study_app/main.dart';
import 'package:study_app/screens/book_shelf_screen.dart';
import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/theme/color.dart';
import 'package:like_button/like_button.dart';
import 'package:study_app/widgets/home/study_summary_card.dart.dart';
import 'package:study_app/widgets/preview_detail.dart/comment_card.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/preview_detail.dart/week_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study_app/widgets/user/goal.dart';
import 'package:study_app/widgets/user/stacked_graph.dart';
import 'package:study_app/widgets/user/tab_bar.dart';
import 'package:study_app/widgets/user/tag.dart';

class OtherUserDisplayCard extends StatefulWidget {
  final String profileImgUrl;
  final String name;
  final int studyTime;

  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final List<double> studyTimes;
  final List<Tag> tags;
  bool isFollow;
  int followNum;
  int followersNum;
  // コンストラクター
  OtherUserDisplayCard(
      {Key? key,
      required this.studyTimes,
      required this.profileImgUrl,
      required this.name,
      required this.studyTime,
      required this.commentNum,
      required this.achivementLevel,
      required this.oneWord,
      required this.tags,
      required this.isFollow,
      required this.followNum,
      required this.followersNum})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OtherUserDisplayCardState();
}

class _OtherUserDisplayCardState extends State<OtherUserDisplayCard> {
  //選択中のタブを保持
  int _selectedIndex = 0;
  // 分(int型)で受け取ってx時間xx分の形式の文字列を返却
  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '${hours}時間${minutes}分';
  }

  //フォローボタンを押した時の処理
  void _onFollow() {
    setState(() {
      if (widget.isFollow) {
        widget.isFollow = false;
        widget.followersNum--;
      } else {
        widget.isFollow = true;
        widget.followersNum++;
      }
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Card(
                child: Padding(
                    padding: EdgeInsets.only(top: 6, left: 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (widget.profileImgUrl.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, bottom: 3, right: 20),
                                child: Container(
                                  width: 42.0,
                                  height: 42.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(21.0),
                                    image: DecorationImage(
                                      image: NetworkImage(widget.profileImgUrl),
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
                              child: ElevatedButton(
                                onPressed: () => {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(60, 50),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
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
                              child: ElevatedButton(
                                onPressed: () => {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
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
                            //いいねを押している場合
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
                                  child: Text("英単語をいっぱい覚えたいです。"),
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 30, top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 35,
                                  width: 120,
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: widget.isFollow
                                        ? Colors.white
                                        : primary,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: primary),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _onFollow,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      widget.isFollow ? "フォロー中" : 'フォロー',
                                      style: TextStyle(
                                        color: widget.isFollow
                                            ? primary
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
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
                          GoalCard(),
                          Card(
                            color: Colors.grey[
                                200], // Set the background color of the card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16), // Rounded corners for the card itself
                            ),
                            elevation:
                                4, // Optional: Elevation for shadow effect
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  5), // Padding inside the card
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Background color of the container
                                  borderRadius: BorderRadius.circular(
                                      16), // Rounded corners for the container
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: primary,
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
                                      studyTimes: [
                                        {'数学': 2, '理科': 1.5},
                                        {'数学': 3, '国語': 1},
                                        {'歴史': 2, '理科': 1},
                                        {'数学': 2, '理科': 1.5},
                                        {'数学': 3, '国語': 1},
                                        {'歴史': 2, '理科': 1},
                                        {'歴史': 2, '理科': 1},
                                      ],
                                      subjects: [
                                        {'name': '数学', 'color': Colors.blue},
                                        {'name': '理科', 'color': Colors.green},
                                        {'name': '歴史', 'color': Colors.red},
                                        {'name': '国語', 'color': primary},
                                        {'name': '国語', 'color': primary},
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookShelf(),
                                      ),
                                    )
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets
                                    .zero, // No padding around the button itself
                                minimumSize:
                                    Size.zero, // Remove the minimum size
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // Shrink the tap target to the child size
                                elevation:
                                    0, // You can adjust the button elevation as needed
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Match the card's rounded corners
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Card(
                                  color: Colors.grey[
                                      100], // Background color for the card
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Rounded corners
                                  ),
                                  elevation: 5, // Shadow depth
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Padding inside the card
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Left-aligned button
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 27),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .orange, // Button background color
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20), // Rounded button
                                              ),
                                              child: Text(
                                                '教材',
                                                style: TextStyle(
                                                  color: Colors
                                                      .white, // Text color
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Right-aligned arrow icon
                                            Icon(
                                              Icons.chevron_right,
                                              color:
                                                  Colors.black, // Arrow color
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            BookCard(
                                              name: "aaa",
                                              bookImgUrl:
                                                  'https://tshop.r10s.jp/learners/cabinet/08213828/08213829/imgrc0091358308.jpg?_ex=200x200&s=0&r=1',
                                              studyTime: 300,
                                            ),
                                            BookCard(
                                              name: "aaa",
                                              bookImgUrl:
                                                  'https://tshop.r10s.jp/learners/cabinet/08213828/08213829/imgrc0091358308.jpg?_ex=200x200&s=0&r=1',
                                              studyTime: 300,
                                            ),
                                            BookCard(
                                              name: "aaa",
                                              bookImgUrl:
                                                  'https://tshop.r10s.jp/learners/cabinet/08213828/08213829/imgrc0091358308.jpg?_ex=200x200&s=0&r=1',
                                              studyTime: 300,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
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
