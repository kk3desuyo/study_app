import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';

class CommentService {
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// dailyGoalIdに基づいてコメントを取得する関数
  Future<List<Comment>> getCommentsByDailyGoalId(String dailyGoalId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('comments')
          .where('dailyGoalId', isEqualTo: dailyGoalId)
          .get();

      List<Comment> comments = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comment.fromFirestore(doc.id, data);
      }).toList();

      return comments;
    } catch (e) {
      print('Error getting comments: $e');
      throw Exception('Failed to get comments');
    }
  }

  // コメントIDに基づいて返信を取得する関数
  Future<List<Reply>> getRepliesByCommentId(String commentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .get();

      List<Reply> replies = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Reply.fromFirestore(doc.id, data);
      }).toList();

      return replies;
    } catch (e) {
      print('Error getting replies: $e');
      throw Exception('Failed to get replies');
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
