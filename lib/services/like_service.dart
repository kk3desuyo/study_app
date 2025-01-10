import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth をインポート

class LikeService {
  final CollectionReference likes =
      FirebaseFirestore.instance.collection('likes');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 特定の投稿のいいね数を取得する関数
  Future<int> getLikeCount(String dailyGoalId) async {
    try {
      // dailyGoalId に基づいて、いいねの数を取得
      QuerySnapshot likeSnapshot =
          await likes.where('dailyGoalId', isEqualTo: dailyGoalId).get();

      // いいね数を返す
      return likeSnapshot.docs.length;
    } catch (e) {
      print('Error getting like count: $e');
      throw Exception('Failed to get like count');
    }
  }

  // 自分が特定の投稿にいいねしているかを確認する関数
  Future<bool> isLikedByCurrentUser(String dailyGoalId) async {
    try {
      // 現在ログイン中のユーザーIDを取得
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // userId と dailyGoalId に基づいて、いいねが存在するか確認
      QuerySnapshot likeSnapshot = await likes
          .where('dailyGoalId', isEqualTo: dailyGoalId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      // いいねが存在すれば true を返し、存在しなければ false を返す
      return likeSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking like status: $e');
      throw Exception('Failed to check like status');
    }
  }

  Future<bool> toggleLike(String dailyGoalId, String dailyGoalUserId,
      bool isLiked, String dailyGoalUserName) async {
    final user = _auth.currentUser;
    if (user == null) {
      // ユーザーがログインしていない場合、何もしない
      return isLiked;
    }
    final userId = user.uid;

    try {
      if (isLiked) {
        // いいねを追加
        await FirebaseFirestore.instance.collection('likes').add({
          'userId': userId,
          'dailyGoalId': dailyGoalId,
          'dailyGoalUserId': dailyGoalUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 通知を追加 (dailyGoalUserId のユーザーに通知)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(dailyGoalUserId)
            .collection('notifications')
            .add({
          'type': 'like',
          'title': 'いいね',
          'dailyGoalId': dailyGoalId,
          'message': '$dailyGoalUserName さんがあなたの目標にいいねしました。',
          'senderName': dailyGoalUserName,
          'timestamp': FieldValue.serverTimestamp(),
          'senderId': userId,
        });
      } else {
        // いいねを削除
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('likes')
            .where('userId', isEqualTo: userId)
            .where('dailyGoalId', isEqualTo: dailyGoalId)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // 新しい状態を返す
      return !isLiked;
    } catch (error) {
      print(error);
      return isLiked;
    }
  }
}
