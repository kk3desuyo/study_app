import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/other/other_user_display_card.dart';
import 'package:study_app/widgets/user/app_bar.dart';
import 'package:study_app/widgets/user/tag.dart';

class OtherUserDisplay extends StatefulWidget {
  const OtherUserDisplay({Key? key}) : super(key: key);

  @override
  State<OtherUserDisplay> createState() => _OtherUserDisplayState();
}

class _OtherUserDisplayState extends State<OtherUserDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBarUser(
        userName: "ss",
      ),
      body: OtherUserDisplayCard(
        followNum: 10,
        followersNum: 10,
        isFollow: true,
        profileImgUrl: "",
        name: "ss",
        studyTime: 370,
        commentNum: 10,
        achivementLevel: 100,
        oneWord: "英単語",
        studyTimes: const [2, 3, 5, 6, 3, 7, 4],
        tags: [
          new Tag(name: "基本情報", id: 0, isAchievement: true),
          new Tag(name: "応用情報", id: 0, isAchievement: false)
        ],
      ),
    );
  }
}
