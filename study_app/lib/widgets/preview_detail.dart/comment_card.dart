import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInfo {
  final String profileUrl;
  final String content;
  final String name;
  final DateTime dateTime;
  final int id;

  // コンストラクタの定義
  CommentInfo({
    required this.profileUrl,
    required this.content,
    required this.name,
    required this.dateTime,
    required this.id,
  });
}

class ReplayInfo {
  final String profileUrl;
  final String content;
  final String name;
  final DateTime dateTime;
  final int id;
  final int replayToId;

  // コンストラクタの定義
  ReplayInfo({
    required this.profileUrl,
    required this.content,
    required this.name,
    required this.dateTime,
    required this.id,
    required this.replayToId,
  });
}

class Comments extends StatefulWidget {
  final List<CommentInfo> comments;
  final List<ReplayInfo> replays;

  Comments({required this.comments, required this.replays});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  Map<int, bool> showAllReplies = {};

  void _onTapCommentModal() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8, // 画面の90%の高さに設定
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 170,
                    height: 10,
                    decoration: BoxDecoration(
                      color: subTheme,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.comments.map((comment) {
                          bool showAll = showAllReplies[comment.id] ?? false;
                          List<ReplayInfo> replies = widget.replays
                              .where(
                                  (replay) => replay.replayToId == comment.id)
                              .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(comment.profileUrl),
                                ),
                                title: Text(comment.name),
                                subtitle: Text(comment.content),
                                trailing: Text(timeAgo(comment.dateTime)),
                              ),
                              // 返信を表示
                              ...replies
                                  .take(showAll ? replies.length : 2)
                                  .map((replay) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40.0),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 12, // アイコンのサイズを小さく
                                            backgroundImage: NetworkImage(
                                              replay.profileUrl,
                                            ),
                                          ),
                                          title: Text(replay.name),
                                          subtitle: Text(replay.content),
                                          trailing:
                                              Text(timeAgo(replay.dateTime)),
                                        ),
                                      ))
                                  .toList(),
                              if (replies.length > 2 && !showAll)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showAllReplies[comment.id] = true;
                                      });
                                    },
                                    child: Text('返信を全て表示'),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 8, left: 5, right: 5),
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
                              color: subTheme,
                            ),
                            onPressed: () {
                              // Send action
                            },
                            padding: EdgeInsets.only(
                                bottom:
                                    2), // Adjust this value to raise the icon
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                decoration: BoxDecoration(
                  color: subTheme,
                  borderRadius: BorderRadius.circular(5),
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
              SizedBox(
                width: 10,
              ),
              Icon(Icons.mode_comment_outlined),
              SizedBox(
                width: 3,
              ),
              Text(widget.comments.length.toString()),
              SizedBox(
                width: 20,
              ),
              Spacer(),
              InkWell(
                onTap: _onTapCommentModal,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: subTheme),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '全てのコメントを表示',
                        style: TextStyle(
                          fontSize: 10,
                          color: subTheme,
                          fontWeight: FontWeight.w900,
                          fontFamily: "KiwiMaru-Regular",
                        ),
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: subTheme,
                        size: 20,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        // コメントが4つ未満の場合はメッセージを表示
        if (widget.comments.isEmpty)
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
          padding: const EdgeInsets.only(top: 10, bottom: 8, left: 5, right: 5),
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
                    color: subTheme,
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

  String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays < 1) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1), // シャドウの位置を調整
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // これで全体の高さを上に揃える
            children: [
              if (profileUrl.isNotEmpty)
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(profileUrl),
                )
              else
                Icon(
                  Icons.account_circle,
                  size: 20.0,
                ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Spacer(), // 名前と時間の間にスペースを追加
              Column(
                mainAxisAlignment: MainAxisAlignment.start, // これで時間の高さを上に揃える
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0), // 上に余白を追加
                    child: Text(
                      timeAgo(dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            content,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
