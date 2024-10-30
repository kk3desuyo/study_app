import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String bookId;
  final bool isTimeChange;
  final String memo;
  final int studyTime;
  final DateTime timeStamp;
  final String userId;

  StudySession({
    required this.id,
    required this.bookId,
    required this.isTimeChange,
    required this.memo,
    required this.studyTime,
    required this.timeStamp,
    required this.userId,
  });

  // FirestoreのドキュメントからStudySessionオブジェクトを作成するファクトリコンストラクタ
  factory StudySession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudySession(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      isTimeChange: data['isTimeChange'] ?? false,
      memo: data['memo'] ?? '',
      studyTime: data['studyTime'] ?? 0,
      timeStamp: (data['timeStamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  // StudySessionオブジェクトをFirestoreに保存するためのMapに変換するメソッド
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'isTimeChange': isTimeChange,
      'memo': memo,
      'studyTime': studyTime,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'userId': userId,
    };
  }
}
