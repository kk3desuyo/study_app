import 'package:flutter/material.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';
import 'package:study_app/models/user.dart'; // Userモデルのインポート
import 'package:study_app/models/studyMaterial.dart'; // StudyMaterialモデルのインポート

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

  @override
  void initState() {
    super.initState();
    fetchStudyMaterials();
    print(widget.dailyGoalId + "A");
    fetchComments();
    fetchReplays();
  }

  Future<void> fetchComments() async {
    try {
      CommentService commentService = CommentService();
      List<Comment> fetchedComments =
          await commentService.getCommentsByDailyGoalId(widget.dailyGoalId);
      setState(() {
        comments = fetchedComments;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> fetchReplays() async {
    try {
      CommentService commentService = CommentService();
      List<Reply> fetchedReplays =
          await commentService.getRepliesByCommentId(widget.dailyGoalId);
      setState(() {
        replays = fetchedReplays;
      });
      print(fetchedReplays);
    } catch (e) {
      print('Error fetching replays: $e');
    }
  }

  Future<void> fetchStudyMaterials() async {
    try {
      UserService userService = UserService();
      List<StudyMaterial> materials =
          await userService.getTodayStudyMaterials(userId: widget.user.id);
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

  @override
  Widget build(BuildContext context) {
    print(studyMaterials);
    print(comments);
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBarPrev(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : DetailCard(
              replays: replays,
              comments: comments,
              studyMaterials: studyMaterials,
              user: widget.user,
              studyTime:
                  studyMaterials.fold(0, (sum, item) => sum + item.studyTime),
              goodNum: 10,
              isPushFavorite: true,
              commentNum: 10,
              achivementLevel: 100,
              oneWord: "英単語のことなら一級品",
              studyTimes: const [2, 3, 5, 6, 3, 7, 4],
            ),
    );
  }
}
