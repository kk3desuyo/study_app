import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/user/user_service.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DailyGoalのtargetStudyTimeとachievedStudyTimeを取得
  Future<Map<String, dynamic>?> fetchDailyGoalData(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserDailyGoals')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        print("Daily Goal Data: $data");
        return {
          'targetStudyTime': data['targetStudyTime'],
          'achievedStudyTime': data['achievedStudyTime'],
        };
      }
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
      await _firestore.collection('WeeklyGoal').doc(weeklyGoalId).update({
        'targetStudyTime': newWeeklyTargetStudyTime,
      });

      // UserDailyGoals の targetStudyTime を更新
      await _firestore.collection('UserDailyGoals').doc(dailyGoalId).update({
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
          .collection('WeeklyGoal')
          .where('userId', isEqualTo: userId)
          .limit(1) // 結果を1件に制限
          .get();

      // 結果が存在する場合、ドキュメントIDを取得
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        print('WeeklyGoal が見つかりませんでした。');
        return null;
      }
    } catch (e) {
      print('Firestore から goalId を取得中にエラーが発生しました: $e');
      return null;
    }
  }

  // userId を元に UserDailyGoals の goalId を取得する関数
  Future<String?> getDailyGoalIdByUserId(String userId) async {
    try {
      // クエリを実行して userId に一致する UserDailyGoals を検索
      QuerySnapshot snapshot = await _firestore
          .collection('UserDailyGoals')
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
