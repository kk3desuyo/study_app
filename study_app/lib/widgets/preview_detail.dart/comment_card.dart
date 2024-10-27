import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';

class Comments extends StatefulWidget {
  final List<Comment> comments;
  final List<Reply> replies;

  Comments({required this.comments, required this.replies});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String timeAgo(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'just now';
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
                        children: widget.comments.map((comment) {
                          bool showAll = showAllReplies[comment.id] ?? false;
                          List<Reply> replies = widget.replies
                              .where((reply) => reply.commentId == comment.id)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String?>(
                                future: _fetchProfileImage(comment.userId),
                                builder: (context, snapshot) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: snapshot.hasData &&
                                              snapshot.data != null
                                          ? NetworkImage(snapshot.data!)
                                          : AssetImage(
                                                  'assets/images/default_avatar.png')
                                              as ImageProvider,
                                    ),
                                    title: Text(comment.userId),
                                    subtitle: Text(comment.content),
                                    trailing: Text(timeAgo(comment.dateTime)),
                                  );
                                },
                              ),
                              ...replies
                                  .take(showAll ? replies.length : 2)
                                  .map((reply) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40.0),
                                        child: FutureBuilder<String?>(
                                          future:
                                              _fetchProfileImage(reply.userId),
                                          builder: (context, snapshot) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                radius: 12,
                                                backgroundImage: snapshot
                                                            .hasData &&
                                                        snapshot.data != null
                                                    ? NetworkImage(
                                                        snapshot.data!)
                                                    : AssetImage(
                                                            'assets/images/default_avatar.png')
                                                        as ImageProvider,
                                              ),
                                              title: Text(reply.userId),
                                              subtitle: Text(reply.content),
                                              trailing:
                                                  Text(timeAgo(reply.dateTime)),
                                            );
                                          },
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
        ...widget.comments.take(4).map((comment) {
          return Padding(
            padding: const EdgeInsets.only(top: 3, left: 9, right: 9),
            child: FutureBuilder<String?>(
              future: _fetchProfileImage(comment.userId),
              builder: (context, snapshot) {
                return CommentCard(
                  user: User(
                    id: comment.userId,
                    name: comment.userId,
                    profileImgUrl: snapshot.data ?? '',
                  ),
                  content: comment.content,
                  dateTime: comment.dateTime,
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final User user;
  final String content;
  final DateTime dateTime;

  CommentCard({
    required this.user,
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
              if (user.profileImgUrl.isNotEmpty)
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(user.profileImgUrl),
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
                    user.name,
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
