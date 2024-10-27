import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String content;
  final DateTime dateTime;
  final String commentId;
  final String userId;

  // コンストラクター
  Reply({
    required this.id,
    required this.content,
    required this.dateTime,
    required this.commentId,
    required this.userId,
  });

  // FirestoreのデータからReplyオブジェクトを生成するファクトリメソッド
  factory Reply.fromFirestore(String id, Map<String, dynamic> data) {
    return Reply(
      id: id,
      content: data['content'] ?? '',
      dateTime:
          (data['dateTime'] as Timestamp).toDate(), // TimestampをDateTimeに変換
      commentId: data['commentId'] ?? '',
      userId: data['userId'] ?? '', // フィールド名をuserIdに統一
    );
  }

  // ReplyオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'dateTime': Timestamp.fromDate(dateTime), // DateTimeをTimestampに変換
      'commentId': commentId,
      'userId': userId, // フィールド名をuserIdに統一
    };
  }
}
