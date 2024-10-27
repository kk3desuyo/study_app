import 'package:flutter/material.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/theme/color.dart';
import 'package:like_button/like_button.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/home/study_summary_card.dart';
import 'package:study_app/widgets/preview_detail.dart/comment_card.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/preview_detail.dart/week_chart.dart';
import 'package:fl_chart/fl_chart.dart';
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

  // コンストラクター
  DetailCard({
    Key? key,
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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            color: Colors.white,
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            elevation: 8,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 8),
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
          widget.user.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Spacer(),
        Text(
          convertMinutesToHoursAndMinutes(widget.studyTime),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        SizedBox(width: 12),
        LikeButton(
          padding: EdgeInsets.only(right: 20),
          isLiked: widget.isPushFavorite,
          likeCount: widget.goodNum,
        ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserDisplay(user: widget.user),
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
          widget.oneWord.isEmpty ? "まだ勉強中かも???" : widget.oneWord,
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
    return '${hours}時間${minutes}分';
  }
}
