import 'package:flutter/material.dart';
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/screens/book.dart';

import 'package:study_app/theme/color.dart';
import 'package:study_app/models/book.dart'; // Bookモデルをインポート

class DisplayBooks extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<StudyMaterial> studyMaterials; // 引数として受け取る

  // コンストラクター
  DisplayBooks({Key? key, required this.studyMaterials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                decoration: BoxDecoration(
                  color: subTheme,
                  borderRadius: BorderRadius.circular(5),
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
        if (studyMaterials.length == 0)
          SizedBox(
            height: 130,
            child: Center(
              child: Text("教材がありません。"),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Scrollbar(
            controller: _scrollController,
            child: Row(
              children: studyMaterials.map((StudyMaterial) {
                return BookCard(
                  book: StudyMaterial.book,
                  isDisplayName: true,
                  studyTime: StudyMaterial.studyTime, // ここは引数として渡すこともできます
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class BookCard extends StatefulWidget {
  final Book book;
  final int studyTime;
  final bool isDisplayTime;
  final bool isDisplayName;
  final bool isTapDisabled;
  const BookCard({
    Key? key,
    required this.book,
    required this.studyTime,
    this.isDisplayTime = true,
    this.isDisplayName = true,
    this.isTapDisabled = false,
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            if (widget.isTapDisabled) {
              print(widget.isTapDisabled);
              print("タップ無効");
              return;
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookScreen(book: widget.book)));
          },
          child: Card(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // ここを修正
              children: [
                if (widget.book.imgUrl.isNotEmpty)
                  Padding(
                    padding:
                        EdgeInsets.only(left: 7, right: 7, top: 7, bottom: 1),
                    child: Container(
                      width: 85.0,
                      height: 110.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Image.network(
                        widget.book.imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_book_img.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  )
                else
                  Image.asset(
                    'assets/images/default_book_img.jpg',
                    fit: BoxFit.cover,
                  ),
                if (widget.isDisplayName) ...[
                  Text(
                    widget.book.title.length > 9
                        ? '${widget.book.title.substring(0, 9)}...'
                        : widget.book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        const SizedBox(height: 1),
        if (widget.isDisplayTime)
          Text(
            convertMinutesToHoursAndMinutes(widget.studyTime),
            style: const TextStyle(fontSize: 14),
          ),
      ],
    );
  }
}
