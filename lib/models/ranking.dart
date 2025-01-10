// models/ranking.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ranking_entry.dart';

class Ranking {
  final String rankingId;
  final DateTime startDate;
  final DateTime endDate;
  final String rankingType;
  final List<RankingEntry> entries;

  Ranking({
    required this.rankingId,
    required this.startDate,
    required this.endDate,
    required this.rankingType,
    required this.entries,
  });

  factory Ranking.fromDocument(
      DocumentSnapshot doc, List<RankingEntry> entries) {
    final data = doc.data() as Map<String, dynamic>;
    return Ranking(
      rankingId: doc.id,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      rankingType: data['rankingType'] ?? '',
      entries: entries,
    );
  }
}
