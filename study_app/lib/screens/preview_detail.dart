import 'package:flutter/material.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/user/user_service.dart'; // CommentServiceからUserServiceに変更
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';
import 'package:study_app/models/user.dart'; // Userモデルのインポート
import 'package:study_app/models/studyMaterial.dart'; // StudyMaterialモデルのインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート

class PreviewDetailScreen extends StatefulWidget {
  final User user;
  final String dailyGoalId;

  const PreviewDetailScreen(
      {Key? key, required this.user, required this.dailyGoalId})
      : super(key: key);

  @override
  State<PreviewDetailScreen> createState() => _PreviewDetailScreenState();
}

class _PreviewDetailScreenState extends State<PreviewDetailScreen> {
  List<StudyMaterial> studyMaterials = [];
  List<Comment> comments = [];
  List<Reply> replays = [];

  bool isLoading = true;
  int goodNum = 0; // goodNumを追加
  int commentNum = 0; // commentNumを追加

  final UserService _userService = UserService(); // UserServiceのインスタンスを作成

  @override
  void initState() {
    super.initState();
    fetchStudyMaterials();
    fetchComments();
    fetchReplays();
    fetchGoodNum(); // goodNumを取得
    // fetchCommentNum(); // コメント数はfetchComments内で取得
  }

  /// コメントを追加し、通知を作成するメソッド
  Future<void> addNewComment({
    required String content,
  }) async {
    try {
      await _userService.addCommentWithNotification(
        dailyGoalId: widget.dailyGoalId,
        content: content,
      );
      print('コメントが正常に追加されました');
      await fetchComments();
    } catch (e) {
      print('コメントの追加に失敗しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コメントの追加に失敗しました。')),
      );
    }
  }

  /// 返信を追加するメソッド（必要に応じてUserServiceに実装）
  Future<void> addNewReply({
    required Reply reply,
  }) async {
    // 返信機能もUserServiceに統合することを検討
    // ここでは既存のCommentServiceを使用し続ける場合の例を示します
    try {
      // 返信の追加処理をUserServiceに実装することを推奨
      // 例: await _userService.addReply(reply);
      // 今回はCommentServiceを使用
      // ただし、通知機能も必要であればUserServiceに統合することを検討
      // 以下は元のCommentServiceを使用する例です
      CommentService commentService = CommentService();
      await commentService.addReply(reply);
      print('返信が正常に追加されました');
      await fetchReplays();
    } catch (e) {
      print('返信の追加に失敗しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('返信の追加に失敗しました。')),
      );
    }
  }

  /// コメントを取得するメソッド
  Future<void> fetchComments() async {
    try {
      List<Comment> fetchedComments =
          await CommentService().getCommentsByDailyGoalId(widget.dailyGoalId);
      setState(() {
        comments = fetchedComments;
        commentNum = comments.length; // コメント数を更新
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  /// 返信を取得するメソッド
  Future<void> fetchReplays() async {
    try {
      CommentService commentService = CommentService();
      List<Reply> fetchedReplays =
          await commentService.getRepliesForDailyGoal(widget.dailyGoalId);
      setState(() {
        replays = fetchedReplays;
      });
      print("${fetchedReplays.length} fetchReplays");
    } catch (e) {
      print('Error fetching replays: $e');
    }
  }

  /// 学習教材を取得するメソッド
  Future<void> fetchStudyMaterials() async {
    try {
      List<StudyMaterial> materials =
          await _userService.getTodayStudyMaterials(userId: widget.user.id);
      setState(() {
        studyMaterials = materials;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching study materials: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// いいね数を取得するメソッド
  Future<void> fetchGoodNum() async {
    try {
      // Query the likes collection to find documents with the matching dailyGoalId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('dailyGoalId', isEqualTo: widget.dailyGoalId)
          .get();

      // Set the goodNum to the count of documents matching the dailyGoalId
      setState(() {
        goodNum = snapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching goodNum: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("studyMaterials");
    print(studyMaterials);
    print(comments);
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBarPrev(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : DetailCard(
              addNewReply: addNewReply,
              addNewComment: addNewComment, // 修正後のaddNewCommentを使用
              dailyGoalId: widget.dailyGoalId,
              replays: replays,
              comments: comments,
              studyMaterials: studyMaterials,
              user: widget.user,
              studyTime:
                  studyMaterials.fold(0, (sum, item) => sum + item.studyTime),
              goodNum: goodNum,
              isPushFavorite: true,
              commentNum: commentNum,
              achivementLevel: 100,
              oneWord: widget.user.oneWord,
              studyTimes: const [2, 3, 5, 6, 3, 7, 4],
            ),
    );
  }
}
