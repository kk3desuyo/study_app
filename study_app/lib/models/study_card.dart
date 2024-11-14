import 'package:study_app/models/book.dart';
import 'package:study_app/models/user.dart';

class StudyCardData {
  final User user;
  final int studyTime;
  final Book book;
  final String memo;
  final String id;
  final DateTime timeStamp;

  StudyCardData({
    required this.user,
    required this.studyTime,
    required this.book,
    required this.memo,
    required this.id,
    required this.timeStamp,
  });
}
