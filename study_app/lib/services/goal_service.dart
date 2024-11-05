import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DailyGoalのtargetStudyTimeとachievedStudyTimeを取得
  Future<Map<String, dynamic>?> fetchDailyGoalData(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('DailyGoals')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
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

  // UserWeeklySummaryのtotalDurationを取得
  Future<int?> fetchUserWeeklySummary(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserWeeklySummary')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['totalDuration'] as int;
      }
      return null;
    } catch (e) {
      print("Error fetching weekly summary: $e");
      return null;
    }
  }

  // WeeklyGoalのtargetTimeを取得
  Future<int?> fetchWeeklyGoal(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('WeeklyGoal')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['targetTime'] as int;
      }
      return null;
    } catch (e) {
      print("Error fetching weekly goal: $e");
      return null;
    }
  }
}
