import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/like_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/controller_manager.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/preview_detail.dart/comment_card.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/models/comment.dart'; // Import the Comment model

class DetailCard extends StatefulWidget {
  final User user;
  final int studyTime;
  final int goodNum;
  bool isPushFavorite;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final List<double> studyTimes;
  final List<StudyMaterial> studyMaterials; // モデルを使った新しい引数
  final List<Comment> comments; // Add comments as a new argument
  final List<Reply> replays; // Add replays as a new argument
  final String dailyGoalId; // Add dailyGoalId as a new argument
  final Function addNewComment; // Add addNewComment as a new argument
  final Function addNewReply;
  // コンストラクター
  DetailCard({
    Key? key,
    required this.addNewReply,
    required this.addNewComment,
    required this.dailyGoalId,
    required this.user,
    required this.studyTimes,
    required this.studyTime,
    required this.goodNum,
    required this.isPushFavorite,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
    required this.studyMaterials,
    required this.comments, // Initialize comments
    required this.replays, // Initialize replays
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    // 非同期でデータベース処理を行う
    try {
      final likeService = LikeService();
      await likeService.toggleLike(
        widget.dailyGoalId,
        widget.user.id,
        isLiked,
        widget.user.name,
      );
    } catch (e) {
      // エラーハンドリング
      print('Error toggling like: $e');
    }

    return isLiked;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.studyTime);
    print("detail" +
        widget.replays.length
            .toString()); // Print the length of the replays list
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            color: Colors.white,
            margin:
                const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
            elevation: 8,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 1, right: 1),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildOneWordSection(),
                  _buildDivider(),
                  _buildDivider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, left: 4),
                    child: DisplayBooks(
                      studyMaterials: widget.studyMaterials,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                    child: Comments(
                      currentUserId: UserService().getCurrentUserId()!,
                      addNewReply: widget.addNewReply,
                      addNewComment: widget.addNewComment,
                      dailyGoalId: widget.dailyGoalId,
                      replies: widget.replays, // Use the replays argument
                      comments: widget.comments, // Use the comments argument
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildProfileImage(context),
        Text(
          widget.user.name.length > 5
              ? '${widget.user.name.substring(0, 5)}...'
              : widget.user.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        Spacer(),
        Text(
          convertMinutesToHoursAndMinutes(widget.studyTime),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(width: 12),
        LikeButton(
            padding: EdgeInsets.only(right: 20),
            isLiked: widget.isPushFavorite,
            likeCount: widget.goodNum,
            onTap: onLikeButtonTapped),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String? currentUserId = UserService().getCurrentUserId();

        if (currentUserId == widget.user.id) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // 自分自身のプロフィールの場合はタブを切り替える
          jumpToTab(4); // タブを「アカウント」に移動
        } else
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return OtherUserDisplay(user: widget.user);
              },
            ),
          );
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 3, right: 20),
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21.0),
            image: widget.user.profileImgUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(widget.user.profileImgUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.user.profileImgUrl.isEmpty
              ? Icon(
                  Icons.account_circle,
                  size: 50.0,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildOneWordSection() {
    return Container(
      height: 70,
      margin: EdgeInsets.only(left: 4, right: 4, bottom: 10),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backGroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "今日めっちゃ集中できた",
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.86,
          height: 1,
          color: Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '$hours時間$minutes分';
  }
}
