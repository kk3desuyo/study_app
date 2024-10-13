import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/home/study_summary_card.dart.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInfo {
  final String profileUrl;
  final String content;
  final String name;
  final DateTime dateTime;
  // コンストラクタの定義
  CommentInfo(
      {required this.profileUrl,
      required this.content,
      required this.name,
      required this.dateTime});
}

class Comments extends StatefulWidget {
  final List<CommentInfo> comments;

  Comments({required this.comments});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: backGroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'コメント',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: "KiwiMaru-Regular"),
                  ),
                ),
                Spacer(),
                Icon(Icons.mode_comment_outlined),
                SizedBox(
                  width: 3,
                ),
                Text(widget.comments.length.toString()),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          // コメントが4つ未満の場合はメッセージを表示
          if (widget.comments.length == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "応援コメントを送ろう!",
                style: GoogleFonts.kiwiMaru(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // コメントのリストから最大4つを表示
          ...widget.comments
              .take(4) // 最初の4つのコメントのみ取得
              .map((comment) => Padding(
                    padding: const EdgeInsets.only(top: 3, left: 9, right: 9),
                    child: CommentCard(
                      profileUrl: comment.profileUrl,
                      userName: comment.name,
                      content: comment.content,
                      dateTime: comment.dateTime,
                    ),
                  ))
              .toList(),

          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 8, left: 5, right: 5),
            child: Container(
              height: 35,
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Ensure button is vertically centered
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'コメントを追加',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      // Send action
                    },
                    padding: EdgeInsets.only(
                        bottom: 2), // Adjust this value to raise the icon
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

String timeAgo(DateTime commentTime) {
  final Duration difference = DateTime.now().difference(commentTime);

  if (difference.inMinutes < 1) {
    return '1分前';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分前';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}時間前';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}日前';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()}週間前';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}か月前';
  } else {
    return '${(difference.inDays / 365).floor()}年前';
  }
}

class CommentCard extends StatelessWidget {
  final String profileUrl;
  final String userName;
  final String content;
  final DateTime dateTime;
  CommentCard({
    required this.profileUrl,
    required this.userName,
    required this.content,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Card(
        margin: EdgeInsets.zero, // Remove the default margin of the Card
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (profileUrl.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 3, left: 10, right: 10),
                    child: Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21.0),
                        image: DecorationImage(
                          image: NetworkImage(profileUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(left: 4, right: 3),
                    child: Icon(
                      Icons.account_circle,
                      size: 22.0,
                    ),
                  ),
                Text(userName),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    timeAgo(this.dateTime),
                    style: TextStyle(fontSize: 13, color: bottomNavInActive),
                  ),
                ),
              ],
            ),
            Text(content)
          ],
        ),
      ),
    );
  }
}
