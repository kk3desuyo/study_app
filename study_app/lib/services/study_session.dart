import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/study_session.dart';
import 'package:study_app/services/book_service.dart';

class StudySessionService {
  final CollectionReference studySessionCollection =
      FirebaseFirestore.instance.collection('studySession');

  final BookService bookService = BookService();
  final CollectionReference dailyGoalsCollection =
      FirebaseFirestore.instance.collection('dailyGoals');
  Future<List<StudySession>> fetchLast7DaysStudySessions(String userId) async {
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    // 指定した userId の studySession を取得
    final QuerySnapshot studySessionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('studySession')
        .where('timeStamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('timeStamp', descending: true)
        .get();

    // 取得した studySession ドキュメントをリストに変換
    return studySessionSnapshot.docs
        .map((doc) => StudySession.fromFirestore(doc))
        .toList();
  }

  Future<List<Map<String, double>>> fetchStudyTimes(String userId) async {
    List<Map<String, double>> studyTimes = [];
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    // studySessionコレクションから過去7日間のデータを取得
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('studySession')
        .where('userId', isEqualTo: userId)
        .where('timeStamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    // 過去7日分のデータを日ごとに分類し、リストに格納
    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: i));
      Map<String, double> dailyStudyTimes = {};

      for (var doc in snapshot.docs) {
        DateTime timeStamp = (doc['timeStamp'] as Timestamp).toDate();

        // 同じ日のデータのみ追加
        if (timeStamp.year == day.year &&
            timeStamp.month == day.month &&
            timeStamp.day == day.day) {
          String bookId = doc['bookId'];
          double studyTime =
              (doc['studyTime'] as int).toDouble() / 60; // 分を時間に変換

          // bookIdからbookNameを取得
          String? bookName = await bookService.fetchBookName(bookId);
          if (bookName != null) {
            dailyStudyTimes[bookName] =
                (dailyStudyTimes[bookName] ?? 0) + studyTime;
          }
        }
      }
      studyTimes.add(dailyStudyTimes);
    }

    return studyTimes.reversed.toList(); // 6日前から当日順に並べ替え
  }

  // StudySessionを追加する関数
  // StudySessionを追加し、DailyGoalのachievedStudyTimeを更新または作成する関数
  Future<void> addStudySession(StudySession session) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // studySessionコレクションに新しいセッションを追加
        DocumentReference studySessionRef = studySessionCollection.doc();
        transaction.set(studySessionRef, session.toFirestore());

        // 今日の日付を文字列で取得
        String todayDate =
            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

        // userIdと今日の日付をもとにdailyGoalドキュメントを検索
        QuerySnapshot dailyGoalSnapshot = await dailyGoalsCollection
            .where('userId', isEqualTo: session.userId)
            .where('targetDay', isEqualTo: todayDate)
            .get();

        if (dailyGoalSnapshot.docs.isNotEmpty) {
          print("存在します");
          // 既存のDailyGoalが存在する場合
          DocumentReference dailyGoalRef =
              dailyGoalSnapshot.docs.first.reference;
          int currentAchievedStudyTime =
              dailyGoalSnapshot.docs.first['achievedStudyTime'];
          int newAchievedStudyTime =
              currentAchievedStudyTime + session.studyTime;
          print(currentAchievedStudyTime);
          print(newAchievedStudyTime);
          // achievedStudyTimeを更新
          transaction.update(dailyGoalRef, {
            'achievedStudyTime': newAchievedStudyTime,
          });
        } else {
          print("存在しません");
          // DailyGoalが存在しない場合、新しいドキュメントを作成
          DocumentReference newDailyGoalRef = dailyGoalsCollection.doc();
          transaction.set(newDailyGoalRef, {
            'achievedStudyTime': session.studyTime,
            'oneWord': '',
            'targetDay': todayDate,
            'targetStudyTime': 0,
            'userId': session.userId,
          });
        }
      });

      print('StudySession added successfully and DailyGoal updated');
    } catch (e) {
      print('Error adding StudySession or updating DailyGoal: $e');
      throw Exception('Failed to add StudySession or update DailyGoal');
    }
  }

  // userIdに基づいてStudySessionを取得する関数
  Future<List<StudySession>> getStudySessionsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await studySessionCollection.where('userId', isEqualTo: userId).get();

      List<StudySession> sessions = querySnapshot.docs.map((doc) {
        return StudySession.fromFirestore(doc);
      }).toList();

      return sessions;
    } catch (e) {
      print('Error getting StudySessions: $e');
      throw Exception('Failed to get StudySessions');
    }
  }

  // studySessionIdに基づいて特定のStudySessionを取得する関数
  Future<StudySession?> getStudySessionById(String studySessionId) async {
    try {
      DocumentSnapshot doc =
          await studySessionCollection.doc(studySessionId).get();

      if (doc.exists) {
        return StudySession.fromFirestore(doc);
      } else {
        print('StudySession not found');
        return null;
      }
    } catch (e) {
      print('Error getting StudySession: $e');
      throw Exception('Failed to get StudySession');
    }
  }

  // // StudySessionを更新する関数
  // Future<void> updateStudySession(
  //     String studySessionId, StudySession session) async {
  //   try {
  //     await studySessionCollection
  //         .doc(studySessionId)
  //         .update(session.toFirestore());
  //     print('StudySession updated successfully');
  //   } catch (e) {
  //     print('Error updating StudySession: $e');
  //     throw Exception('Failed to update StudySession');
  //   }
  // }

  // StudySessionを削除する関数
  Future<void> deleteStudySession(String studySessionId) async {
    try {
      await studySessionCollection.doc(studySessionId).delete();
      print('StudySession deleted successfully');
    } catch (e) {
      print('Error deleting StudySession: $e');
      throw Exception('Failed to delete StudySession');
    }
  }
}
