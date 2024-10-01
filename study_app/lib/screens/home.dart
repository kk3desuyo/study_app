import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/bottom_navigation.dart';
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
      backgroundColor: Color.fromRGBO(
          backGroundColorR, backGroundColorG, backGroundColorB, 1),
      appBar: MyAppBar(),
      body: Stack(
        children: [
          // データが読み込まれている場合のリスト
          if (_isDataLoaded) ...[
            ListView(
              children: [
                const SizedBox(height: 60), // TabBarの高さ分スペースを確保
                StudySummaryCard(
                  profileImgUrl: testUrl,
                  name: "上達",
                  studyTime: 370,
                  goodNum: 10,
                  isPushGood: true,
                  commentNum: 10,
                  achivementLevel: 100,
                  oneWord: "英単語のことなら一級品",
                ),
                StudySummaryCard(
                  profileImgUrl: testUrl,
                  name: "上達",
                  studyTime: 370,
                  goodNum: 10,
                  isPushGood: true,
                  commentNum: 10,
                  achivementLevel: 100,
                  oneWord: "英単語のことなら一級品",
                ),
                StudySummaryCard(
                  profileImgUrl: testUrl,
                  name: "上達",
                  studyTime: 370,
                  goodNum: 10,
                  isPushGood: true,
                  commentNum: 10,
                  achivementLevel: 100,
                  oneWord: "英単語のことなら一級品",
                ),
                StudySummaryCard(
                  profileImgUrl: testUrl,
                  name: "上達",
                  studyTime: 370,
                  goodNum: 10,
                  isPushGood: true,
                  commentNum: 10,
                  achivementLevel: 100,
                  oneWord: "英単語のことなら一級品",
                ),
              ],
            ),
          ] else ...[
            // 読み込み中のローディング表示
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color:
                    const Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1),
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
