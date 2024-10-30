import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/models/user.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference follows =
      FirebaseFirestore.instance.collection('follows');
  final CollectionReference studySessions =
      FirebaseFirestore.instance.collection('studySession');

  // Firebase Authのインスタンス
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // ユーザーIDをAuthから取得する関数
  String? getCurrentUserId() {
    auth.User? user = _auth.currentUser;
    print(user?.uid);
    return user?.uid;
  }

// ユーザーが今日勉強した教材とその勉強時間を取得する関数
  Future<List<StudyMaterial>> getTodayStudyMaterials(
      {required String userId}) async {
    try {
      // 今日の開始と終了のTimestampを取得
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // FirestoreでユーザーIDと今日の日付の範囲を条件にクエリ
      QuerySnapshot querySnapshot = await studySessions
          .where('userId', isEqualTo: userId)
          .where('timeStamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timeStamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // クエリ結果をリストに変換し、StudyMaterialオブジェクトを生成
      List<StudyMaterial> studyMaterialsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return StudyMaterial.fromFirestore(data);
      }).toList();

      return studyMaterialsList;
    } catch (e) {
      print('Error getting today\'s study materials: $e');
      throw Exception('Failed to get today\'s study materials');
    }
  } // ユーザーのプロフィール画像URLを取得する関数

  Future<String?> getUserProfileImage(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['profileImgUrl'] as String?;
      }
      return null; // ユーザーが見つからない場合
    } catch (e) {
      print('Error getting user profile image: $e');
      throw Exception('Failed to get user profile image');
    }
  }

  // フォローしているユーザーのIDを全て取得する関数
  Future<List<String>> getFollowedUserIds() async {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      List<String> followedUserIds = [];

      // フォローしているユーザーのIDを取得
      QuerySnapshot followsSnapshot =
          await follows.where('followUserId', isEqualTo: currentUserId).get();

      for (var doc in followsSnapshot.docs) {
        String followingUserId = doc['followingUserId'];
        followedUserIds.add(followingUserId);
      }

      return followedUserIds;
    } catch (e) {
      print('Error getting followed users: $e');
      throw Exception('Failed to get followed users');
    }
  }

  // 例: フォローしているユーザーのデータを取得
  Future<List<User>> getFollowedUsers() async {
    List<String> followedUserIds = await getFollowedUserIds();
    List<User> followedUsers = [];

    try {
      for (String userId in followedUserIds) {
        User? user = await getUser(userId);
        if (user != null) {
          followedUsers.add(user);
        }
      }

      return followedUsers;
    } catch (e) {
      print('Error getting followed user data: $e');
      throw Exception('Failed to get followed user data');
    }
  }

  // Firestoreからユーザーを取得する
  Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      throw Exception('Failed to get user');
    }
  }

  // ユーザーの名前を取得する関数
  Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['name'] as String?;
      }
      return null; // ユーザーが見つからない場合
    } catch (e) {
      print('Error getting user name: $e');
      throw Exception('Failed to get user name');
    }
  }
}
