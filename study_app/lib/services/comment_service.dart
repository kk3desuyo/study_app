import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  // 指定された dailyGoalId に関連するコメントを取得する関数
  Future<List<Map<String, dynamic>>> getCommentsByDailyGoalId(
      String dailyGoalId) async {
    try {
      // 指定された dailyGoalId に関連するコメントをクエリ
      QuerySnapshot commentSnapshot =
          await comments.where('dailyGoalId', isEqualTo: dailyGoalId).get();

      // クエリ結果をリストに変換
      List<Map<String, dynamic>> commentList = commentSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return commentList;
    } catch (e) {
      print('Error getting comments: $e');
      throw Exception('Failed to get comments');
    }
  }

  // 指定された dailyGoalId に関連するコメント数を取得する関数
  Future<int> getCommentCountByDailyGoalId(String dailyGoalId) async {
    try {
      // 指定された dailyGoalId に関連するコメントをクエリ
      QuerySnapshot commentSnapshot =
          await comments.where('dailyGoalId', isEqualTo: dailyGoalId).get();

      // コメント数を返す
      return commentSnapshot.size;
    } catch (e) {
      print('Error getting comment count: $e');
      throw Exception('Failed to get comment count');
    }
  }
}
