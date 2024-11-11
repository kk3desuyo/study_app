import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/controller_manager.dart';

class Comments extends StatefulWidget {
  final List<Comment> comments;
  final List<Reply> replies;
  final String dailyGoalId;
  final Function addNewComment;
  final Function addNewReply;
  final String currentUserId;

  Comments({
    required this.comments,
    required this.addNewReply,
    required this.replies,
    required this.dailyGoalId,
    required this.addNewComment,
    required this.currentUserId,
  });

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _commentController = TextEditingController();
  UserService userService = UserService();
  Map<String, String?> profileImageCache = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String?> _fetchProfileImage(String userId) async {
    if (profileImageCache.containsKey(userId)) {
      return profileImageCache[userId];
    }

    try {
      String? imgUrl = await userService.getUserProfileImage(userId);
      profileImageCache[userId] = imgUrl;
      return imgUrl;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  void _onTapCommentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(
          onDeleteComment: onDeleteComment,
          comments: widget.comments,
          replies: widget.replies,
          dailyGoalId: widget.dailyGoalId,
          addNewComment: widget.addNewComment,
          addNewReply: widget.addNewReply,
          userService: userService,
          profileImageCache: profileImageCache,
        ),
      ),
    );
  }

  void onDeleteComment(String commentId) {
    setState(() {
      widget.comments.removeWhere((comment) => comment.id == commentId);
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
                onTap: _onTapCommentScreen,
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
                  onTap: _onTapCommentScreen, // アイコンと名前以外の部分をタップしたとき
                  child: Row(
                    children: [
                      // アイコンと名前のタップでプロフィール画面に遷移

                      const SizedBox(width: 8),
                      // コメントのコンテンツ部分
                      Expanded(
                        child: CommentCard(
                          currentUserId: widget.currentUserId,
                          onDeleteComment: onDeleteComment,
                          commentId: comment.id,
                          onTapCommentScreen: _onTapCommentScreen,
                          user: User(
                            id: comment.userId,
                            name: comment.userName,
                            profileImgUrl: snapshot.data ?? '',
                          ),
                          content: comment.content,
                          dateTime: comment.dateTime,
                        ),
                      ),
                    ],
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
                    if (content.isEmpty) return;
                    String userId =
                        (await userService.getCurrentUserId()) ?? '';
                    String userName = (await userService.getUserName(userId)) ??
                        'Unknown User';
                    DateTime dateTime = DateTime.now();

                    widget.addNewComment(
                      content: content,
                    );

                    setState(() {
                      widget.comments.insert(
                        0,
                        Comment(
                          id: '',
                          content: content,
                          dateTime: dateTime,
                          userId: userId,
                          userName: userName,
                          dailyGoalId: widget.dailyGoalId,
                        ),
                      );
                    });

                    _commentController.clear();
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

class CommentScreen extends StatefulWidget {
  final List<Comment> comments;
  final List<Reply> replies;
  final String dailyGoalId;
  final Function addNewComment;
  final Function addNewReply;
  final UserService userService;
  final Map<String, String?> profileImageCache;
  final Function(String) onDeleteComment;

  CommentScreen({
    required this.comments,
    required this.replies,
    required this.dailyGoalId,
    required this.addNewComment,
    required this.addNewReply,
    required this.userService,
    required this.profileImageCache,
    required this.onDeleteComment,
  });

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController _commentController = TextEditingController();
  Comment? _selectedComment;
  Map<String, bool> showAllReplies = {};
  double _offsetX = 0.0;

  List<Comment> modalComments = []; // コメントリスト
  bool isLoadingMore = false; // ロード中フラグ
  bool hasMoreComments = true; // 追加のコメントがあるかどうか
  DocumentSnapshot? lastDocument; // 最後に取得したドキュメント

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    modalComments = List.from(widget.comments);
    if (modalComments.isNotEmpty) {
      lastDocument = modalComments.last.documentSnapshot;
    }
    _initializeShowAllReplies();
    _scrollController.addListener(_onScroll);
  }

  void _initializeShowAllReplies() {
    for (var comment in modalComments) {
      List<Reply> replies = widget.replies
          .where((reply) => reply.commentId == comment.id)
          .toList();
      showAllReplies[comment.id] = replies.length < 3;
    }
  }

  void onDeleteComment(String commentId) {
    widget.onDeleteComment(commentId);
    setState(() {
      modalComments.removeWhere((comment) => comment.id == commentId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore &&
        hasMoreComments) {
      setState(() {
        isLoadingMore = true;
      });
      await _loadMoreComments();
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreComments() async {
    CommentService commentService = CommentService();
    List<Comment> newComments = await commentService.getCommentsByDailyGoalId(
      widget.dailyGoalId,
      limit: 10,
      lastDocument: lastDocument,
    );

    if (newComments.isNotEmpty) {
      setState(() {
        modalComments.addAll(newComments);
        lastDocument = newComments.last.documentSnapshot;
        _initializeShowAllReplies();
      });
    } else {
      setState(() {
        hasMoreComments = false;
      });
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

  Future<String?> _fetchProfileImage(String userId) async {
    if (widget.profileImageCache.containsKey(userId)) {
      return widget.profileImageCache[userId];
    }

    try {
      String? imgUrl = await widget.userService.getUserProfileImage(userId);
      widget.profileImageCache[userId] = imgUrl;
      return imgUrl;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  String _truncateText(String text) {
    return text.length > 30 ? '${text.substring(0, 30)}...' : text;
  }

  void _toggleShowAllReplies(String commentId) {
    setState(() {
      showAllReplies[commentId] = !(showAllReplies[commentId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Reply> modalReplies = List.from(widget.replies);

    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: MyAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: modalComments.map((comment) {
                  List<Reply> replies = widget.replies
                      .where((reply) => reply.commentId == comment.id)
                      .toList();

                  return FutureBuilder<String?>(
                    future: _fetchProfileImage(comment.userId),
                    builder: (context, snapshot) {
                      String profileImageUrl = snapshot.data ?? '';
                      return CommentItem(
                        onDeleteComment: onDeleteComment,
                        comment: comment,
                        profileImageUrl: profileImageUrl,
                        replies: replies,
                        onSelectComment: (Comment selectedComment) {
                          setState(() {
                            _selectedComment = selectedComment;
                          });
                        },
                        showAllReplies: showAllReplies,
                        toggleShowAllReplies: _toggleShowAllReplies,
                        fetchProfileImage: _fetchProfileImage,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          if (isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
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
            padding:
                const EdgeInsets.only(top: 10, bottom: 8, left: 5, right: 5),
            child: Container(
              height: 50,
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
                          (await widget.userService.getCurrentUserId()) ?? '';
                      String userName =
                          (await widget.userService.getUserName(userId)) ??
                              'Unknown User';
                      DateTime dateTime = DateTime.now();

                      if (_selectedComment == null) {
                        widget.addNewComment(
                          content: content,
                        );

                        setState(() {
                          modalComments.insert(
                            0,
                            Comment(
                              id: '', // 適切なIDを設定
                              content: content,
                              dateTime: dateTime,
                              userId: userId,
                              userName: userName,
                              dailyGoalId: widget.dailyGoalId,
                            ),
                          );
                        });
                      } else {
                        widget.addNewReply(
                          reply: Reply(
                            id: '',
                            content: content,
                            dateTime: dateTime,
                            commentId: _selectedComment?.id ?? '',
                            userId: userId,
                            userName: userName,
                          ),
                        );

                        setState(() {
                          widget.replies.add(
                            Reply(
                              id: '',
                              content: content,
                              dateTime: dateTime,
                              commentId: _selectedComment?.id ?? '',
                              userId: userId,
                              userName: userName,
                            ),
                          );
                        });
                      }
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
  }

  // リプライウィジェットの構築
  Widget _buildReplyWidget(Reply reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
      child: FutureBuilder<String?>(
        future: _fetchProfileImage(reply.userId),
        builder: (context, snapshot) {
          String profileImageUrl = snapshot.data ?? '';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () async {
                  String? currentUserId =
                      await UserService().getCurrentUserId();
                  if (reply.userId == currentUserId) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    jumpToTab(4); // タブを「アカウント」に移動
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserDisplay(
                          user: User(
                            id: reply.userId,
                            name: reply.userName,
                            profileImgUrl: profileImageUrl,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () async {
                        String? currentUserId =
                            await UserService().getCurrentUserId();
                        if (reply.userId == currentUserId) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          jumpToTab(4);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserDisplay(
                                user: User(
                                  id: reply.userId,
                                  name: reply.userName,
                                  profileImgUrl: profileImageUrl,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        reply.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
          );
        },
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final User user;
  final String content;
  final DateTime dateTime;
  final Function() onTapCommentScreen;
  final String commentId;
  final Function(String) onDeleteComment;
  final String currentUserId;
  CommentCard({
    required this.commentId,
    required this.user,
    required this.content,
    required this.dateTime,
    required this.onTapCommentScreen,
    required this.onDeleteComment,
    required this.currentUserId,
  });

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
      onTap: onTapCommentScreen,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // メインのコメント内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // プロフィール画像をタップするとプロフィール画面に遷移
                    GestureDetector(
                      onTap: () async {
                        String? currentUserId =
                            await UserService().getCurrentUserId();
                        if (currentUserId == user.id) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          jumpToTab(4); // タブを「アカウント」に移動
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserDisplay(
                                user: user,
                              ),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: user.profileImgUrl.isNotEmpty
                            ? NetworkImage(user.profileImgUrl)
                            : AssetImage('assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 10),
                    // 名前をタップするとプロフィール画面に遷移
                    GestureDetector(
                      onTap: () async {
                        String? currentUserId =
                            await UserService().getCurrentUserId();
                        if (currentUserId == user.id) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          jumpToTab(4); // タブを「アカウント」に移動
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserDisplay(
                                user: user,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        user.name.length > 9
                            ? '${user.name.substring(0, 9)}...'
                            : user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      timeAgo(dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            // 右下に配置するメニューアイコン
            Positioned(
              bottom: -10,
              right: -10,
              child: PopupMenuButton<String>(
                icon: Transform.rotate(
                  angle: 90 * 3.1415927 / 180,
                  child: Icon(Icons.more_horiz, color: Colors.grey),
                ),
                onSelected: (String choice) async {
                  if (choice == 'ブロックする') {
                    try {
                      UserService userService = UserService();
                      userService.blockUser(user.id);
                      print('ユーザーをブロックしました: ${user.name}');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ユーザーのブロックに失敗しました: $e'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    print('ユーザーをブロックしました: ${user.name}');
                  } else if (choice == 'コメントを消去') {
                    CommentService commentService = CommentService();
                    commentService.deleteComment(commentId);
                    onDeleteComment(commentId);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  if (user.id != currentUserId)
                    PopupMenuItem<String>(
                      value: 'ブロックする',
                      child: Text('ブロックする'),
                    ),
                  PopupMenuItem<String>(
                    value: 'コメントを消去',
                    child: Text('コメントを消去'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Comment comment;
  final String profileImageUrl;
  final List<Reply> replies;
  final Function(Comment) onSelectComment;
  final Map<String, bool> showAllReplies;
  final Function(String) toggleShowAllReplies;
  final Future<String?> Function(String userId) fetchProfileImage;
  final Function(String) onDeleteComment;
  CommentItem({
    required this.comment,
    required this.profileImageUrl,
    required this.replies,
    required this.onSelectComment,
    required this.showAllReplies,
    required this.toggleShowAllReplies,
    required this.fetchProfileImage,
    required this.onDeleteComment,
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  double _offsetX = 0.0;

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0) {
      setState(() {
        _offsetX += details.delta.dx;
      });
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _offsetX = 0.0;
    });
    widget.onSelectComment(widget.comment);
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

  String _truncateText(String text) {
    return text.length > 30 ? '${text.substring(0, 30)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final replies = widget.replies;

    return GestureDetector(
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? currentUserId =
                              await UserService().getCurrentUserId();
                          if (comment.userId == currentUserId) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            jumpToTab(4);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserDisplay(
                                  user: User(
                                    profileImgUrl: widget.profileImageUrl,
                                    name: comment.userName,
                                    id: comment.userId,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: widget.profileImageUrl.isNotEmpty
                              ? NetworkImage(widget.profileImageUrl)
                              : AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      String? currentUserId =
                                          await UserService()
                                              .getCurrentUserId();
                                      if (comment.userId == currentUserId) {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        jumpToTab(4);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserDisplay(
                                              user: User(
                                                profileImgUrl:
                                                    widget.profileImageUrl,
                                                name: comment.userName,
                                                id: comment.userId,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      comment.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  timeAgo(comment.dateTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              comment.content,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      for (int i = 0; i < replies.length; i++)
                        if (i < 2 ||
                            (widget.showAllReplies[comment.id] ?? false))
                          _buildReplyWidget(replies[i]),
                      if (replies.length > 2)
                        TextButton(
                          onPressed: () {
                            widget.toggleShowAllReplies(comment.id);
                          },
                          child: Text(
                            widget.showAllReplies[comment.id] == true
                                ? '隠す'
                                : '全ての返信を表示',
                            style: TextStyle(color: subTheme),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: -10,
                right: -10,
                child: PopupMenuButton<String>(
                  icon: Transform.rotate(
                    angle: 90 * 3.1415927 / 180,
                    child: Icon(Icons.more_horiz, color: Colors.grey),
                  ),
                  onSelected: (String choice) async {
                    if (choice == 'ブロックする') {
                      UserService userService = UserService();
                      userService.blockUser(comment.userId);
                    } else if (choice == 'コメントを消去') {
                      CommentService commentService = CommentService();
                      commentService.deleteComment(comment.id);
                      widget.onDeleteComment(comment.id);
                      print('コメントを消去しました' + comment.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'ブロックする',
                      child: Text('ブロックする'),
                    ),
                    PopupMenuItem<String>(
                      value: 'コメントを消去',
                      child: Text('コメントを消去'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyWidget(Reply reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
      child: FutureBuilder<String?>(
        future: widget.fetchProfileImage(reply.userId),
        builder: (context, snapshot) {
          String profileImageUrl = snapshot.data ?? '';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () async {
                  String? currentUserId =
                      await UserService().getCurrentUserId();
                  if (reply.userId == currentUserId) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    jumpToTab(4);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserDisplay(
                          user: User(
                            id: reply.userId,
                            name: reply.userName,
                            profileImgUrl: profileImageUrl,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () async {
                        String? currentUserId =
                            await UserService().getCurrentUserId();
                        if (reply.userId == currentUserId) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          jumpToTab(4);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserDisplay(
                                user: User(
                                  id: reply.userId,
                                  name: reply.userName,
                                  profileImgUrl: profileImageUrl,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        reply.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
          );
        },
      ),
    );
  }
}
