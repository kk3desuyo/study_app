// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ranking.dart';
import '../models/ranking_entry.dart';

class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // ranksフィールドからweeklyRankを取得する関数
  Future<int> getUserWeeklyRank(String userId) async {
    try {
      // usersコレクションから該当ユーザーのドキュメントを取得
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _db.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        // ranksマップからweeklyRankフィールドを取得
        Map<String, dynamic> ranks = userDoc.data()!['ranks'] ?? {};
        return ranks['weeklyRank'] ?? 0; // デフォルト値は0
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      print('Error fetching weeklyRank: $e');
      throw e; // エラーを呼び出し元に伝播
    }
  }

  // ranksフィールドからmonthlyRankを取得する関数
  Future<int> getUserMonthlyRank(String userId) async {
    try {
      // usersコレクションから該当ユーザーのドキュメントを取得
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _db.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        // ranksマップからmonthlyRankフィールドを取得
        Map<String, dynamic> ranks = userDoc.data()!['ranks'] ?? {};
        return ranks['monthlyRank'] ?? 0; // デフォルト値は0
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      print('Error fetching monthlyRank: $e');
      throw e; // エラーを呼び出し元に伝播
    }
  }

  Stream<List<Ranking>> getRankings(String rankingType) {
    return _db
        .collection('rankings')
        .where('rankingType', isEqualTo: rankingType)
        .orderBy('startDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Ranking> rankings = [];
      try {
        for (var doc in snapshot.docs) {
          // Fetch ranking entries
          QuerySnapshot entriesSnapshot = await doc.reference
              .collection('rankingEntries')
              .orderBy('rank')
              .get();

          List<RankingEntry> entries = entriesSnapshot.docs
              .map((e) => RankingEntry.fromDocument(e))
              .toList();

          rankings.add(Ranking.fromDocument(doc, entries));
        }
      } catch (e, stack) {
        print('Error fetching rankings: $e');
        print('Stack trace: $stack');
        throw Exception('Failed to fetch rankings: $e');
      }
      return rankings;
    });
  }
}
