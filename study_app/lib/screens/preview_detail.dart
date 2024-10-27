import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';
import 'package:study_app/models/user.dart'; // Userモデルのインポート

class PreviewDetailScreen extends StatefulWidget {
  const PreviewDetailScreen({Key? key}) : super(key: key);

  @override
  State<PreviewDetailScreen> createState() => _PreviewDetailScreenState();
}

class _PreviewDetailScreenState extends State<PreviewDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Userインスタンスの作成
    User user = User(
      profileImgUrl: "",
      name: "じょうたつ",
      id: "user_id",
    );

    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBarPrev(),
      body: DetailCard(
        user: user,
        studyTime: 370,
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
