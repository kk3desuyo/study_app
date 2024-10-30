import 'package:flutter/material.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';
import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';

class Comments extends StatefulWidget {
  final List<Comment> comments;
  final List<Reply> replies;
  final String dailyGoalId;
  final Function addNewComment;
  final Function addNewReply;

  Comments(
      {required this.comments,
      required this.addNewReply,
      required this.replies,
      required this.dailyGoalId,
      required this.addNewComment});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _commentController = TextEditingController();
  Comment? _selectedComment; // 選択されたコメントを保持する変数

  @override
  void initState() {
    super.initState();
    _initializeShowAllReplies();
  }

  void _initializeShowAllReplies() {
    for (var comment in widget.comments) {
      List<Reply> replies = widget.replies
          .where((reply) => reply.commentId == comment.id)
          .toList();
      showAllReplies[comment.id] = replies.length < 3;
    }

    for (var entry in showAllReplies.entries) {
      print('Comment ID: ${entry.key}, Show All Replies: ${entry.value}');
    }
  }

  String timeAgo(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays >= 1) {
      return '${diff.inDays} 日前';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} 時間前';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} 分前';
    } else {
      return 'たった今';
    }
  }

  Map<String, bool> showAllReplies = {};
  Map<String, String?> profileImageCache = {};
  UserService userService = UserService();

  Future<String?> _fetchProfileImage(String userId) async {
    if (profileImageCache.containsKey(userId)) {
      return profileImageCache[userId];
    }

    try {
      String? imageUrl = await userService.getUserProfileImage(userId);
      profileImageCache[userId] = imageUrl;
      return imageUrl;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

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
            List<Comment> sortedComments = List.from(widget.comments)
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

            double _offsetX = 0.0; // ドラッグのオフセットを管理する変数

            // 文字列を30文字以上で省略する関数
            String _truncateText(String text) {
              return text.length > 30 ? '${text.substring(0, 30)}...' : text;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
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
                        children: sortedComments.map((comment) {
                          // リプライをフィルタリングして取得
                          List<Reply> replies = widget.replies
                              .where((reply) => reply.commentId == comment.id)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  // 右から左にドラッグされた場合のみ動かす
                                  if (details.delta.dx < 0) {
                                    setState(() {
                                      _offsetX += details.delta.dx;
                                    });
                                  }
                                },
                                onHorizontalDragEnd: (details) {
                                  // ドラッグが終わったら元の位置に戻す
                                  setState(() {
                                    _offsetX = 0.0;
                                    _selectedComment = comment;
                                  });
                                },
                                child: Transform.translate(
                                  offset: Offset(_offsetX, 0),
                                  child: FutureBuilder<String?>(
                                    future: _fetchProfileImage(comment.userId),
                                    builder: (context, snapshot) {
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtherUserDisplay(
                                                          user: User(
                                                            profileImgUrl:
                                                                snapshot.data ??
                                                                    '',
                                                            name: comment
                                                                .userName,
                                                            id: comment.userId,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: snapshot
                                                                .hasData &&
                                                            snapshot.data !=
                                                                null
                                                        ? NetworkImage(
                                                            snapshot.data!)
                                                        : AssetImage(
                                                                'assets/images/default_avatar.png')
                                                            as ImageProvider,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              comment.userName,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            timeAgo(comment
                                                                .dateTime),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        comment.content,
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // リプライの表示
                                            Column(
                                              children: [
                                                for (int i = 0;
                                                    i < replies.length;
                                                    i++)
                                                  if (i < 2 ||
                                                      (showAllReplies[
                                                              comment.id] ??
                                                          false))
                                                    _buildReplyWidget(
                                                        replies[i]),
                                                if (replies.length > 2)
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        showAllReplies[
                                                                comment.id] =
                                                            !(showAllReplies[
                                                                    comment
                                                                        .id] ??
                                                                false);
                                                      });
                                                    },
                                                    child: Text(
                                                      showAllReplies[
                                                                  comment.id] ==
                                                              true
                                                          ? '隠す'
                                                          : '全ての返信を表示',
                                                      style: TextStyle(
                                                          color: subTheme),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (_selectedComment != null)
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '返信先: ${_selectedComment?.userName}\n"${_truncateText(_selectedComment?.content ?? "")}"',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedComment = null;
                              });
                            },
                          ),
                        ],
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
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'コメントを追加',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: subTheme),
                            onPressed: () async {
                              String content = _commentController.text;
                              if (content.isEmpty) return;
                              String userId =
                                  (await userService.getCurrentUserId()) ?? '';
                              String userName =
                                  (await userService.getUserName(userId)) ??
                                      'Unknown User';
                              DateTime dateTime = DateTime.now();
                              if (_selectedComment == null)
                                widget.addNewComment(
                                  content: content,
                                  dailyGoalId: widget.dailyGoalId,
                                  dateTime: dateTime,
                                  userName: userName,
                                  userId: userId,
                                );
                              else
                                widget.addNewReply(
                                    reply: Reply(
                                  id: '',
                                  content: content,
                                  dateTime: dateTime,
                                  commentId: _selectedComment?.id ?? '',
                                  userId: userId,
                                  userName: userName,
                                ));
                              _commentController.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper function to build a reply widget
  Widget _buildReplyWidget(Reply reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: Colors.grey,
          ),
          SizedBox(width: 5),
          FutureBuilder<String?>(
            future: _fetchProfileImage(reply.userId),
            builder: (context, snapshot) {
              return CircleAvatar(
                radius: 10,
                backgroundImage: snapshot.hasData && snapshot.data != null
                    ? NetworkImage(snapshot.data!)
                    : AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              );
            },
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                Text(
                  reply.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  reply.content,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Comment> sortedComments = List.from(widget.comments)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
                  ),
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.mode_comment_outlined),
              SizedBox(width: 3),
              Text(widget.comments.length.toString()),
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
              ),
            ],
          ),
        ),
        if (widget.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
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
        ...sortedComments.take(4).map((comment) {
          return Padding(
            padding: const EdgeInsets.only(left: 9, right: 9),
            child: FutureBuilder<String?>(
              future: _fetchProfileImage(comment.userId),
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserDisplay(
                          user: User(
                            profileImgUrl: snapshot.data ?? '',
                            name: comment.userName,
                            id: comment.userId,
                          ),
                        ),
                      ),
                    );
                  },
                  child: CommentCard(
                    user: User(
                      id: comment.userId,
                      name: comment.userName,
                      profileImgUrl: snapshot.data ?? '',
                    ),
                    content: comment.content,
                    dateTime: comment.dateTime,
                  ),
                );
              },
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8, left: 5, right: 5),
          child: Container(
            height: 35,
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: backGroundColor,
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
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _commentController,
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
                  onPressed: () async {
                    String content = _commentController.text;
                    print(content);
                    if (content.isEmpty) return;
                    String userId = (await userService.getCurrentUserId()) ??
                        ''; // そのままawaitで取得
                    String userName = (await userService.getUserName(userId)) ??
                        'Unknown User'; // 同様にそのままawaitで取得
                    DateTime dateTime = DateTime.now();
                    // toString()は不要

                    if (_selectedComment == null)
                      widget.addNewComment(
                        content: content,
                        dailyGoalId: widget.dailyGoalId,
                        dateTime: dateTime,
                        userName: userName,
                        userId: userId,
                      );
                    else
                      widget.addNewReply(
                          reply: Reply(
                        id: '',
                        content: content,
                        dateTime: dateTime,
                        commentId: _selectedComment?.id ?? '',
                        userId: userId,
                        userName: userName,
                      ));
                    _commentController.clear();

                    _commentController.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CommentCard extends StatefulWidget {
  final User user;
  final String content;
  final DateTime dateTime;
  final isShowAll;

  CommentCard({
    required this.user,
    required this.content,
    required this.dateTime,
    this.isShowAll = true,
  });

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0.0;
  bool _isDragging = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // 右から左にドラッグされた場合のみ動かす
    if (details.delta.dx < 0) {
      setState(() {
        _offsetX += details.delta.dx;
        _isDragging = true;
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // ドラッグが終わったら元の位置に戻る
    setState(() {
      _isDragging = false;
    });

    // アニメーションで元の位置に戻す
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _offsetX = 0.0;
      });
    });
  }

  String timeAgo(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays >= 1) {
      return '${diff.inDays} 日前';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} 時間前';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} 分前';
    } else {
      return 'たった今';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform.translate(
        offset: Offset(_offsetX, 0), // 水平方向にオフセットを適用
        child: Container(
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
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.user.profileImgUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(widget.user.profileImgUrl),
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
                        widget.user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          timeAgo(widget.dateTime),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.content,
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
