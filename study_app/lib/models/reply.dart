import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String content;
  final DateTime dateTime;
  final String commentId;
  final String userId;
  String userName; // Added userName field

  // コンストラクター
  Reply({
    required this.id,
    required this.content,
    required this.dateTime,
    required this.commentId,
    required this.userId,
    required this.userName, // Added userName parameter
  });

  // FirestoreのデータからReplyオブジェクトを生成するファクトリメソッド
  factory Reply.fromFirestore(
      String id, Map<String, dynamic> data, String commentId) {
    return Reply(
      id: id,
      content: data['content'] ?? '',
      dateTime:
          (data['dateTime'] as Timestamp).toDate(), // TimestampをDateTimeに変換
      commentId: commentId ?? '',
      userId: data['userId'] ?? '', // フィールド名をuserIdに統一
      userName: data['userName'] ?? '', // Added userName field
    );
  }

  // ReplyオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'dateTime': Timestamp.fromDate(dateTime), // DateTimeをTimestampに変換
      'commentId': commentId,
      'userId': userId, // フィールド名をuserIdに統一
      'userName': userName, // Added userName field
    };
  }
}
