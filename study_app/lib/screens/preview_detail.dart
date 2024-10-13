import 'package:flutter/material.dart';

import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/detail_card.dart';

class PreviewDetailScreen extends StatefulWidget {
  const PreviewDetailScreen({Key? key}) : super(key: key);

  @override
  State<PreviewDetailScreen> createState() => _PreviewDetailScreenState();
}

class _PreviewDetailScreenState extends State<PreviewDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(),
      body: DetailCard(
        profileImgUrl: "",
        name: "じょうたつ",
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
