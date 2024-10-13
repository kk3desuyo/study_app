import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/main.dart';
import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';
import 'package:like_button/like_button.dart';

class StudySummaryCard extends StatefulWidget {
  final String profileImgUrl;
  final String name;
  final int studyTime;
  final int goodNum;
  final bool isPushFavorite;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final String userId;

  // コンストラクター
  const StudySummaryCard({
    Key? key,
    required this.profileImgUrl,
    required this.name,
    required this.studyTime,
    required this.goodNum,
    required this.isPushFavorite,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StudySummaryCardState();
}

class _StudySummaryCardState extends State<StudySummaryCard> {
  //分(int型)で受け取ってx時間xx分の形式の文字列を返却
  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '${hours}時間${minutes}分';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // ここで必要なアクションを実行する（例: 詳細画面に遷移）
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewDetailScreen(),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                if (widget.profileImgUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // プロフィール画像がタップされたときにOtherUserDisplayへ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserDisplay(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, top: 10, bottom: 3, right: 20),
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
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      // アイコンがタップされたときにOtherUserDisplayへ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserDisplay(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.account_circle,
                      size: 42.0,
                    ),
                  ),
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Text(
                  convertMinutesToHoursAndMinutes(widget.studyTime),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.chevron_right),
                ),
              ],
            ),
            HitoKotoCard(oneWord: widget.oneWord),
            ProgressCard(achivementLevel: widget.achivementLevel),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.mode_comment_outlined),
                Text(widget.commentNum.toString()),
                SizedBox(
                  width: 10,
                ),
                LikeButton(
                  padding: EdgeInsets.only(right: 20),
                  isLiked: widget.isPushFavorite,
                  likeCount: widget.goodNum,
                ),
              ],
            )
          ],
        ),
        color: Colors.white,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class HitoKotoCard extends StatelessWidget {
  final String oneWord;

  HitoKotoCard({Key? key, required this.oneWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.only(left: 4, right: 4),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backGroundColor, // 背景色を設定
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        // Containerの中央に配置
        child: Text(
          oneWord.isEmpty ? "まだ勉強中かも???" : oneWord,
          textAlign: TextAlign.center, // テキストを中央揃え
          softWrap: true, // テキストが折り返されるように設定
          style: TextStyle(
            fontSize: 16, // 必要に応じてフォントサイズを調整
          ),
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final int? achivementLevel;

  const ProgressCard({Key? key, required this.achivementLevel})
      : super(key: key); // コンストラクタを修正

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18, bottom: 9),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "目標達成度",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                achivementLevel != null ? achivementLevel.toString() : "-",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: const Text("%"),
              )
            ],
          ),
          GradientProgressBar(value: (achivementLevel ?? 0) / 100)
        ],
      ),
    ));
  }
}

class GradientProgressBar extends StatelessWidget {
  final double value;

  GradientProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: MediaQuery.of(context).size.width *
          0.85, // Width of the entire progress bar
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300], // background color for the remaining part
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width *
                0.85 *
                value, // Progress width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.orange, Colors.deepOrangeAccent],
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Container(
                  color: Colors.white, // Just for the gradient to appear
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
