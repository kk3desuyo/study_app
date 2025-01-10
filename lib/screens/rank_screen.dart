// screens/ranking_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/services/ranking_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/ranking/tab_bar.dart';

import '../models/ranking.dart';
import '../models/ranking_entry.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // ここで変数を宣言します
  final RankingService _rankingService = RankingService();

  int _selectedIndex = 0; // buildメソッド外に移動
  int rank = -1; // 初期値を設定

  int _weeklyRank = -1;
  int _monthlyRank = -1;

  @override
  void initState() {
    super.initState();
    _loadUserRanks();
  }

  Future<void> _loadUserRanks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final weeklyRank = await _rankingService.getUserWeeklyRank(user.uid);
        final monthlyRank = await _rankingService.getUserMonthlyRank(user.uid);
        setState(() {
          _weeklyRank = weeklyRank;
          _monthlyRank = monthlyRank;
          // 初期値を週間ランキングに設定
          rank = _weeklyRank;
        });
      } catch (e) {
        print('Error loading user ranks: $e');
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      rank = index == 0 ? _weeklyRank : _monthlyRank;
    });
    print(index);
  }

  Widget _buildRankingList(Stream<List<Ranking>> rankingsStream) {
    return StreamBuilder<List<Ranking>>(
      stream: rankingsStream,
      builder: (context, snapshot) {
        // 以下、省略せずに全文表示します
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // ログにエラーを出力
          print('StreamBuilder Error: ${snapshot.error}');
          print('StreamBuilder StackTrace: ${snapshot.stackTrace}');

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64.0,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'エラーが発生しました',
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      snapshot.error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10.0,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'ランキングデータがありません',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
            ),
          );
        } else {
          final rankings = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10,
            ),
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              final ranking = rankings[index];
              final topEntries = ranking.entries.take(10).toList();
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ranking.rankingType == 'weekly' ? '週間ランキング' : '月間ランキング',
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${_formatDate(ranking.startDate)} 〜 ${_formatDate(ranking.endDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: topEntries.length,
                        itemBuilder: (context, idx) {
                          final entry = topEntries[idx];
                          return _buildRankingEntry(entry);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildRankingEntry(RankingEntry entry) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24.0,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            entry.userIdProfileImg,
            width: 48.0,
            height: 48.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person, // デフォルトのMaterial Iconを表示
                size: 48.0,
                color: Colors.grey,
              );
            },
          ),
        ),
      ),
      title: Text(
        entry.userName,
        style: GoogleFonts.poppins(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '勉強時間: ${_formatStudyTime(entry.achievedStudyTime)}',
        style: GoogleFonts.poppins(),
      ),
      trailing: Text(
        '#${entry.rank}',
        style: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: _rankColor(entry.rank),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatStudyTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}時間 ${mins}分';
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyRankings = _rankingService.getRankings('weekly');
    final monthlyRankings = _rankingService.getRankings('monthly');

    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          MyTabBar(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 8.0, right: 8),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 中央に配置
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: subTheme, // Button background color
                        borderRadius:
                            BorderRadius.circular(5), // Rounded button
                      ),
                      child: Text(
                        '勉強時間ランク',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(), // スペーサーを追加して位置を調整
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end, // 下に揃える
                      children: [
                        if (rank == -1)
                          Text(
                            '----',
                            style: TextStyle(
                                color: primary, // Text color
                                fontWeight: FontWeight.bold,
                                fontSize: 35),
                          )
                        else
                          Text(
                            '134',
                            style: TextStyle(
                                color: textTeme, // Text color
                                fontWeight: FontWeight.bold,
                                fontSize: 35),
                          ),
                        SizedBox(
                          width: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10), // 位置を調整
                          child: Text(
                            '位',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: textTeme),
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // スペーサーを追加して位置を調整
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            // ここで Expanded を追加
            child: _selectedIndex == 0
                ? _buildRankingList(weeklyRankings)
                : _buildRankingList(monthlyRankings),
          ),
        ],
      ),
    );
  }
}
