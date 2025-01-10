import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/user/user_service.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _getIsoWeek(DateTime date) {
    // 年の最初の日を取得
    final firstDayOfYear = DateTime(date.year, 1, 1);
    // 年の最初の月曜日を取得
    final daysToMonday = (firstDayOfYear.weekday - DateTime.monday) % 7;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysToMonday));

    // 現在の年の最初の月曜日より前の場合、前年に属する可能性がある
    if (date.isBefore(firstMonday)) {
      return _getIsoWeek(DateTime(date.year - 1, 12, 31));
    }

    // 経過日数を計算し、週番号を求める
    final difference = date.difference(firstMonday).inDays;
    final weekNumber = (difference / 7).ceil() + 1;

    // ISO週形式の文字列を返す
    return "${date.year}-W$weekNumber";
  }

  Future<Map<String, dynamic>?> fetchDailyGoalData(String userId) async {
    try {
      // 今日の日付の開始と終了を定義
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Firestoreクエリ
      QuerySnapshot snapshot = await _firestore
          .collection('DailySummary')
          .where('userId', isEqualTo: userId)
          .where('targetDay',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('targetDay', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        print("Daily Goal Data: $data");
        return {
          'targetStudyTime': data['targetStudyTime'],
          'achievedStudyTime': data['achievedStudyTime'],
        };
      }
      print("No data found for today's date.");
      return null;
    } catch (e) {
      print("Error fetching daily goal data: $e");
      return null;
    }
  }

  final CollectionReference weeklyGoalCollection =
      FirebaseFirestore.instance.collection('WeeklySummary');

  Future<Map<String, dynamic>?> fetchWeeklyGoalAndSummary(String userId) async {
    try {
      print("Fetching data for userId: $userId");
      QuerySnapshot querySnapshot =
          await weeklyGoalCollection.where('userId', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        print("Document found: ${doc.id}, Data: ${doc.data()}");

        return {
          "achievedStudyTime": doc['achievedStudyTime'] ?? 0,
          "targetStudyTime": doc['targetStudyTime'] ?? 0,
          "targetWeek": doc['targetWeek'] ?? '',
          "userId": doc['userId'],
        };
      } else {
        print("No documents found for userId: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching WeeklyGoal: $e");
      return null;
    }
  }

  // WeeklyGoal と UserDailyGoals の targetStudyTime を更新する関数
  Future<void> updateTargetStudyTimes({
    required int newWeeklyTargetStudyTime,
    required int newDailyTargetStudyTime,
  }) async {
    try {
      // 現在のユーザーIDを取得
      UserService userService = UserService();
      String? userId = await userService.getCurrentUserId();
      if (userId == null) {
        throw Exception('ユーザーIDの取得に失敗しました。');
      }
      // WeeklyGoal の goalId を取得
      String? weeklyGoalId = await getWeeklyGoalIdByUserId(userId);
      print('取得した WeeklyGoal の goalId: $weeklyGoalId');

      // UserDailyGoals の goalId を取得
      String? dailyGoalId = await getDailyGoalIdByUserId(userId);
      print('取得した UserDailyGoals の goalId: $dailyGoalId');
      // WeeklyGoal の targetStudyTime を更新
      await _firestore.collection('WeeklySummary').doc(weeklyGoalId).update({
        'targetStudyTime': newWeeklyTargetStudyTime,
      });

      // UserDailyGoals の targetStudyTime を更新
      await _firestore.collection('DailySummary').doc(dailyGoalId).update({
        'targetStudyTime': newDailyTargetStudyTime,
      });

      print('targetStudyTime が正常に更新されました。');
    } catch (e) {
      print('Firestore 更新中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // userId を元に WeeklyGoal の goalId を取得する関数
  Future<String?> getWeeklyGoalIdByUserId(String userId) async {
    try {
      print(userId);
      // クエリを実行して userId に一致する WeeklyGoal を検索
      QuerySnapshot snapshot = await _firestore
          .collection('WeeklySummary')
          .where('userId', isEqualTo: userId)
          .limit(1) // 結果を1件に制限
          .get();

      // 結果が存在する場合、ドキュメントIDを取得
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        String? goalId = await addWeeklySummary(
          userId: userId,
          achievedStudyTime: 0,
          targetStudyTime: 0,
          targetWeek: _getIsoWeek(DateTime.now()),
        );
        return goalId;
      }
    } catch (e) {
      print('Firestore から goalId を取得中にエラーが発生しました: $e');
      return null;
    }
  }

  /// WeeklySummaryを追加し、ドキュメントIDを返却する関数
  Future<String?> addWeeklySummary({
    required String userId,
    required int achievedStudyTime,
    required int targetStudyTime,
    required String targetWeek,
  }) async {
    try {
      // WeeklySummaryコレクションへの参照
      CollectionReference weeklySummary =
          _firestore.collection('WeeklySummary');

      // データを追加し、DocumentReferenceを取得
      DocumentReference docRef = await weeklySummary.add({
        'userId': userId,
        'achievedStudyTime': achievedStudyTime,
        'targetStudyTime': targetStudyTime,
        'targetWeek': targetWeek,
      });

      print('WeeklySummary successfully added! DocID: ${docRef.id}');
      return docRef.id; // ドキュメントIDを返却
    } catch (e) {
      print('Failed to add WeeklySummary: $e');
      return null; // エラー時はnullを返却
    }
  }

  // userId を元に UserDailyGoals の goalId を取得する関数
  Future<String?> getDailyGoalIdByUserId(String userId) async {
    try {
      // クエリを実行して userId に一致する UserDailyGoals を検索
      QuerySnapshot snapshot = await _firestore
          .collection('DailySummary')
          .where('userId', isEqualTo: userId)
          .limit(1) // 結果を1件に制限
          .get();

      // 結果が存在する場合、ドキュメントIDを取得
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        print('UserDailyGoals が見つかりませんでした。');
        return null;
      }
    } catch (e) {
      print('Firestore から goalId を取得中にエラーが発生しました: $e');
      return null;
    }
  }
}
