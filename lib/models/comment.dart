import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String dailyGoalId;
  final DateTime dateTime;
  final String userId;
  final String userName; // Add userName field
  final DocumentSnapshot? documentSnapshot; // 修正: プロパティ名を統一

  // コンストラクター
  Comment({
    required this.id,
    required this.content,
    required this.dailyGoalId,
    required this.dateTime,
    required this.userId,
    required this.userName, // Add userName to constructor
    this.documentSnapshot,
  });

  // FirestoreのデータからCommentオブジェクトを生成するファクトリメソッド
  factory Comment.fromFirestore(String id, Map<String, dynamic> data,
      {DocumentSnapshot? documentSnapshot}) {
    return Comment(
      id: id,
      content: data['content'] ?? '',
      dailyGoalId: data['dailyGoalId'] ?? '',
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '', // Add userName to factory method
      documentSnapshot: documentSnapshot, // 修正
    );
  }

  // CommentオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'dailyGoalId': dailyGoalId,
      'dateTime': dateTime,
      'userId': userId,
      'userName': userName, // Add userName to map
    };
  }
}
