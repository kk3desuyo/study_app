import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String dailyGoalId;
  final DateTime dateTime;

  final String userId;

  // コンストラクター
  Comment({
    required this.id,
    required this.content,
    required this.dailyGoalId,
    required this.dateTime,
    required this.userId,
  });

  // FirestoreのデータからCommentオブジェクトを生成するファクトリメソッド
  factory Comment.fromFirestore(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      content: data['content'] ?? '',
      dailyGoalId: data['dailyGoalId'] ?? '',
      dateTime:
          (data['dateTime'] as Timestamp).toDate(), // TimestampをDateTimeに変換

      userId: data['userid'] ?? '',
    );
  }

  // CommentオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'dailyGoalId': dailyGoalId,
      'dateTime': dateTime,
      'userid': userId,
    };
  }
}
