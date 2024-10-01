import 'package:flutter/material.dart';

class StudySummaryCard extends StatefulWidget {
  final profileImgUrl;
  final name;
  final studyTime;
  final goodNum;
  final isPushGood;
  final commentNum;
  final achivementLevel;
  final oneWord;

  // コンストラクター
  const StudySummaryCard({
    Key? key,
    required this.profileImgUrl,
    required this.name,
    required this.studyTime,
    required this.goodNum,
    required this.isPushGood,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
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
        // カード全体がタップされたときに実行するアクション
        print('${widget.name} のカードがタップされました');
      },
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                if (widget.profileImgUrl.isNotEmpty)
                  Padding(
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
                  )
                else
                  Icon(
                    Icons.account_circle,
                    size: 42.0,
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
          ],
        ),
        color: Colors.white,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
      margin: EdgeInsets.only(left: 10, right: 15),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'ひとこと',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Text(oneWord.isEmpty ? "まだ勉強中かも???" : oneWord),
          )
        ],
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
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "目標達成度",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
          0.8, // Width of the entire progress bar
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300], // background color for the remaining part
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width *
                0.8 *
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
