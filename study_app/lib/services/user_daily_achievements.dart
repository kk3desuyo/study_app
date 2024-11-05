import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/services/user/user_service.dart';

class UserDailyAchievementsService {
  final CollectionReference achievementsCollection =
      FirebaseFirestore.instance.collection('userDailyAchievements');

  // Streamで実績データを取得
  Stream<List<DateTime>> getAchievementDatesStream() {
    // ユーザーIDを取得
    UserService userService = UserService();
    String? userId = userService.getCurrentUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    return achievementsCollection
        .where(FieldPath.documentId, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // デバッグ用のprint文
      print('Snapshot received: ${snapshot.docs.length} documents');
      return snapshot.docs.map((doc) {
        // doc.data()がnullでないことを確認してからachievementDateフィールドの存在をチェック
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null &&
            data.containsKey('achievementDate') &&
            data['achievementDate'] != null) {
          Timestamp timestamp = data['achievementDate'];
          print('Achievement date found: ${timestamp.toDate()}');
          return timestamp.toDate();
        } else {
          print('Achievement date not found, returning current date');
          return DateTime.now(); // 必要に応じてエラーハンドリング
        }
      }).toList();
    });
  }
}
