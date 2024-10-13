import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:study_app/widgets/home/study_summary_card.dart.dart';
import 'package:study_app/widgets/home/tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDataLoaded = false; // データベースからの読み込み完了フラグ
  int _selectedIndex = 0; // 現在の選択されているタブのインデックス

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final testUrl =
      "https://lh3.googleusercontent.com/a/AItbvmn9YJ5sdBnrBlBqVN1Eu6ZB9QD5K8tzLDxX6ONo=s96-c";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: backGroundColor,
      body: Stack(
        children: [
          // データが読み込まれている場合のリスト
          if (!_isDataLoaded) ...[
            ListView(
              children: [
                const SizedBox(height: 60), // TabBarの高さ分スペースを確保
                StudySummaryCard(
                    profileImgUrl: testUrl,
                    name: "ss",
                    studyTime: 370,
                    goodNum: 10,
                    isPushFavorite: true,
                    commentNum: 10,
                    achivementLevel: 100,
                    oneWord: "がんばった",
                    userId: "jo"),
                StudySummaryCard(
                    profileImgUrl: testUrl,
                    name: "ssd",
                    studyTime: 370,
                    goodNum: 10,
                    isPushFavorite: true,
                    commentNum: 10,
                    achivementLevel: 100,
                    oneWord: "がんばった",
                    userId: "jo"),
                StudySummaryCard(
                    profileImgUrl: testUrl,
                    name: "上達",
                    studyTime: 370,
                    goodNum: 10,
                    isPushFavorite: true,
                    commentNum: 10,
                    achivementLevel: 100,
                    oneWord: "がんばった",
                    userId: "jo"),
                StudySummaryCard(
                    profileImgUrl: testUrl,
                    name: "上達",
                    studyTime: 370,
                    goodNum: 10,
                    isPushFavorite: true,
                    commentNum: 10,
                    achivementLevel: 100,
                    oneWord: "がんばった",
                    userId: "jo"),
              ],
            ),
          ] else ...[
            // 読み込み中のローディング表示
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: primary,
                size: 80,
              ),
            ),
          ],
          // TabBarを上に重ねる
          Positioned(
            top: 0, // 上部に配置
            left: 0,
            right: 0,
            child: MyTabBar(
              selectedIndex: _selectedIndex,
              onTabSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
