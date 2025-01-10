import 'dart:ui'; // 追加: ブラー効果のために必要
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:study_app/main.dart';
import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/like_service.dart';
import 'package:study_app/services/user/app/app_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/controller_manager.dart';

import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';

import 'package:study_app/models/user.dart' as customUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class StudySummaryCard extends StatefulWidget {
  final customUser.User user;
  final int studyTime;
  final int goodNum;
  final bool isPushFavorite;
  final int commentNum;
  final int achivementLevel;
  final String oneWord;
  final String dailyGoalId;
  bool isCurrentUserSummary;

  StudySummaryCard({
    Key? key,
    required this.user,
    required this.studyTime,
    required this.goodNum,
    required this.isPushFavorite,
    required this.commentNum,
    required this.achivementLevel,
    required this.oneWord,
    required this.dailyGoalId,
    this.isCurrentUserSummary = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StudySummaryCardState();
}

class _StudySummaryCardState extends State<StudySummaryCard> {
  int likeCountFinally = 0;

  @override
  void initState() {
    super.initState();
    likeCountFinally = widget.goodNum;
  }

  String convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}時間${minutes}分';
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    if (isLiked) {
      likeCountFinally++;
    } else {
      likeCountFinally--;
    }

    try {
      final likeService = LikeService();
      await likeService.toggleLike(
        widget.dailyGoalId,
        widget.user.id,
        isLiked,
        widget.user.name,
      );
    } catch (e) {
      print('Error toggling like: $e');
    }

    return isLiked;
  }

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context, listen: false);

    return StreamBuilder<DocumentSnapshot>(
      stream: appService.getAppSettingsStream(),
      builder: (context, snapshot) {
        bool needBlur = true;
        bool isStudyTimeVisible = true;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            // ブラー状態を判定
            final timestamp = data['visibilityTime'] as Timestamp?;
            final visibilityTime = timestamp?.toDate();
            if (visibilityTime != null) {
              needBlur = DateTime.now().isBefore(visibilityTime);
            }

            // isStudyTimeVisible の値を取得
            isStudyTimeVisible = data['isStudyTimeVisible'] ?? true;
            print("isStudyTimeVisible: $isStudyTimeVisible");
          }
        }

        Widget cardContent = Column(
          children: [
            Row(
              children: [
                if (widget.user.profileImgUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      String? currentUserId = UserService().getCurrentUserId();
                      if (currentUserId == widget.user.id) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        jumpToTab(4);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserDisplay(
                              user: widget.user,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, top: 4, bottom: 3, right: 20),
                      child: Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          image: DecorationImage(
                            image: NetworkImage(widget.user.profileImgUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      String? currentUserId = UserService().getCurrentUserId();
                      if (currentUserId == widget.user.id) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        jumpToTab(4);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserDisplay(
                              user: widget.user,
                            ),
                          ),
                        );
                      }
                    },
                    child: Icon(
                      Icons.account_circle,
                      size: 42.0,
                    ),
                  ),
                Text(
                  widget.user.name.length > 5
                      ? '${widget.user.name.substring(0, 5)}...'
                      : widget.user.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Text(
                  convertMinutesToHoursAndMinutes(widget.studyTime),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.chevron_right),
                ),
              ],
            ),
            HitoKotoCard(oneWord: widget.oneWord),
            ProgressCard(achivementLevel: widget.achivementLevel),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.mode_comment_outlined),
                Text(widget.commentNum.toString()),
                SizedBox(width: 10),
                if (!widget.isCurrentUserSummary)
                  LikeButton(
                    padding: EdgeInsets.only(right: 20),
                    isLiked: widget.isPushFavorite,
                    likeCount: widget.goodNum,
                    onTap: onLikeButtonTapped,
                  ),
              ],
            )
          ],
        );

        // ブラー効果を適用
        if (needBlur && !isStudyTimeVisible) {
          cardContent = ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                cardContent,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewDetailScreen(
                  dailyGoalId: widget.dailyGoalId,
                  user: widget.user,
                ),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            elevation: 8,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: cardContent,
          ),
        );
      },
    );
  }
}

class HitoKotoCard extends StatelessWidget {
  final String oneWord;

  HitoKotoCard({Key? key, required this.oneWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.only(left: 4, right: 4),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backGroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          oneWord.isEmpty ? "            " : oneWord,
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final int? achivementLevel;

  const ProgressCard({Key? key, required this.achivementLevel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18, bottom: 9),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "今日の目標達成度",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                achivementLevel != null ? achivementLevel.toString() : "-",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: const Text("%"),
              )
            ],
          ),
          GradientProgressBar(value: (achivementLevel ?? 0) / 100)
        ],
      ),
    ));
  }
}

class GradientProgressBar extends StatelessWidget {
  final double value;

  GradientProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85 * value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primary, Colors.deepOrangeAccent],
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
