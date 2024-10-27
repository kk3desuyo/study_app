import 'package:flutter/material.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/theme/color.dart';
import 'package:like_button/like_button.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/preview_detail.dart/comment_card.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/preview_detail.dart/week_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailCard extends StatefulWidget {
  final User user;
  final int studyTime;
  final int goodNum;
  bool isPushFavorite;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final List<double> studyTimes;

  // コンストラクター
  DetailCard({
    Key? key,
    required this.user,
    required this.studyTimes,
    required this.studyTime,
    required this.goodNum,
    required this.isPushFavorite,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  // 分(int型)で受け取ってx時間xx分の形式の文字列を返却
  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '${hours}時間${minutes}分';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
                padding: EdgeInsets.only(top: 10, left: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.user.profileImgUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              // プロフィール画像がタップされたときにOtherUserDisplayへ遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserDisplay(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10, top: 10, bottom: 3, right: 20),
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(21.0),
                                  image: DecorationImage(
                                    image:
                                        NetworkImage(widget.user.profileImgUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              // アイコンがタップされたときにOtherUserDisplayへ遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserDisplay(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.account_circle,
                              size: 50.0,
                            ),
                          ),
                        Text(
                          widget.user.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          convertMinutesToHoursAndMinutes(widget.studyTime),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        SizedBox(width: 12),
                        //いいねを押している場合
                        LikeButton(
                          padding: EdgeInsets.only(right: 20),
                          isLiked: widget.isPushFavorite,
                          likeCount: widget.goodNum,
                        ),
                      ],
                    ),
                    Container(
                      height: 70,
                      margin: EdgeInsets.only(left: 4, right: 4, bottom: 10),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: backGroundColor, // 背景色を設定
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        // Containerの中央に配置
                        child: Text(
                          widget.oneWord.isEmpty
                              ? "まだ勉強中かも???"
                              : widget.oneWord,
                          textAlign: TextAlign.center, // テキストを中央揃え
                          softWrap: true, // テキストが折り返されるように設定
                          style: TextStyle(
                            fontSize: 16, // 必要に応じてフォントサイズを調整
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.86,
                          height: 1,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child:
                          ProgressCard(achivementLevel: widget.achivementLevel),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, left: 4),
                      child: DisplayBooks(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                      child: Comments(
                        replays: [
                          ReplayInfo(
                            replayToId: 1,
                            id: 1,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "1",
                            ),
                            content: "1",
                          ),
                          ReplayInfo(
                            replayToId: 1,
                            id: 2,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "2",
                            ),
                            content: "2",
                          ),
                          ReplayInfo(
                            replayToId: 1,
                            id: 3,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "3",
                            ),
                            content: "3",
                          ),
                          ReplayInfo(
                            replayToId: 1,
                            id: 4,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "4",
                            ),
                            content: "4",
                          ),
                        ],
                        comments: [
                          CommentInfo(
                            id: 1,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "11",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 2,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "12",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 3,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "13",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 4,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "14",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 5,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "15",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 6,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "16",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 7,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "17",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 8,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "18",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 9,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "19",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 10,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "20",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 11,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "21",
                            ),
                            content: "aaaa",
                          ),
                          CommentInfo(
                            id: 12,
                            dateTime: DateTime.now(),
                            user: User(
                              profileImgUrl:
                                  "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c",
                              name: "jo",
                              id: "22",
                            ),
                            content: "aaaa",
                          ),
                        ],
                      ),
                    )
                  ],
                )),
            color: Colors.white,
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            elevation: 8,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
    );
  }
}
