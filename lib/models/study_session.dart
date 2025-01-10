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

  // Firestoreから生成
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

  // Firestoreに保存する形式
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

  // ローカルデータベース(Hive)用のMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'isTimeChange': isTimeChange,
      'memo': memo,
      'studyTime': studyTime,
      'timeStamp': timeStamp.toIso8601String(),
      'userId': userId,
    };
  }

  // ローカルデータベース(Hive)から生成
  static StudySession fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      bookId: map['bookId'],
      isTimeChange: map['isTimeChange'],
      memo: map['memo'],
      studyTime: map['studyTime'],
      timeStamp: DateTime.parse(map['timeStamp']),
      userId: map['userId'],
    );
  }
}
