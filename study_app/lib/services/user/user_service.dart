import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Firebase Authをエイリアスでインポート
import 'package:study_app/models/user.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference follows =
      FirebaseFirestore.instance.collection('follows');

  // Firebase Authのインスタンス
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // ユーザーIDをAuthから取得する関数
  String? getCurrentUserId() {
    auth.User? user = _auth.currentUser;
    return user?.uid;
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

  // 他のUserService関数...
}
