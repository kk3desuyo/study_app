import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class DisplayBooks extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backGroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 13),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '教材',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: "KiwiMaru-Regular"),
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Scrollbar(
              controller: _scrollController,
              child: Row(
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
                    bookImgUrl: '',
                    studyTime: 300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  final String bookImgUrl;
  final int studyTime;
  final bool isDisplayTime;
  final String name;

  const BookCard({
    Key? key,
    required this.name,
    required this.bookImgUrl,
    required this.studyTime,
    this.isDisplayTime = true,
  }) : super(key: key);

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}時間${minutes}分';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // 画像とテキストを縦に配置
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.bookImgUrl.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 78.0,
                        height: 110.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Image.network(
                          widget.bookImgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.menu_book,
                              size: 65,
                            );
                          },
                        ),
                      )
                    ],
                  )
                else
                  const Icon(
                    Icons.menu_book,
                    size: 70,
                  ),
                const SizedBox(height: 5), // 画像と本の名前の間にスペースを追加
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name.length > 9
                          ? '${widget.name.substring(0, 9)}...' // 7文字以上の場合は7文字まで+...
                          : widget.name, // 7文字未満の場合はそのまま表示
                      maxLines: 1, // 一行に制限
                      overflow: TextOverflow.ellipsis, // 念のため省略処理も追加
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold, // 太字にして目立たせる
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 1), // 画像とテキストの間にスペースを追加
        if (widget.isDisplayTime)
          Text(
            convertMinutesToHoursAndMinutes(widget.studyTime),
            style: const TextStyle(fontSize: 14),
          ),
      ],
    );
  }
}
