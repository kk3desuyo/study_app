// models/ranking_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingEntry {
  final String userId;
  final int achievedStudyTime;
  final int rank;
  final DateTime updatedAt;
  final String userName;
  final String userIdProfileImg;

  RankingEntry({
    required this.userId,
    required this.achievedStudyTime,
    required this.rank,
    required this.updatedAt,
    required this.userName,
    required this.userIdProfileImg,
  });

  factory RankingEntry.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RankingEntry(
      userId: data['userId'] ?? '',
      achievedStudyTime: data['achievedStudyTime'] ?? 0,
      rank: data['rank'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userName: data['userName'] ?? '',
      userIdProfileImg: data['userIdProfileImg'] ?? '',
    );
  }
}
