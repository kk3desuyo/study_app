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
        print("hhhhhhh" + data.toString());
        return Comment.fromFirestore(doc.id, data);
      }).toList();
      print(comments[0].userName + " sss");
      return comments;
    } catch (e) {
      print('Error getting comments: $e');
      throw Exception('Failed to get comments');
    }
  }

// dailyGoalIdに関連するすべての返信を取得する関数
  Future<List<Reply>> getRepliesForDailyGoal(String dailyGoalId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // dailyGoalIdに一致するcommentsコレクションのドキュメントを取得
    QuerySnapshot commentsSnapshot = await firestore
        .collection('comments')
        .where('dailyGoalId', isEqualTo: dailyGoalId)
        .get();

    List<Reply> allReplies = [];

    // 各コメントドキュメントのrepliesサブコレクションから返信を取得
    for (var commentDoc in commentsSnapshot.docs) {
      // コメントIDを取得
      String commentId = commentDoc.id;

      // repliesサブコレクションを取得
      QuerySnapshot repliesSnapshot =
          await commentDoc.reference.collection('replies').get();

      // 返信ドキュメントをReplyオブジェクトに変換してリストに追加
      allReplies.addAll(repliesSnapshot.docs.map((replyDoc) {
        return Reply.fromFirestore(
            replyDoc.id, replyDoc.data() as Map<String, dynamic>, commentId);
      }).toList());
    }

    return allReplies;
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

  // コメントを追加する関数
  Future<void> addComment(Comment comment) async {
    try {
      // 新しいコメントをFirestoreに追加
      await comments.add({
        'content': comment.content,
        'dailyGoalId': comment.dailyGoalId,
        'dateTime': comment.dateTime,
        'userName': comment.userName,
        'userId': comment.userId,
      });
      print('Comment added successfully' + comment.content);
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment');
    }
  }

  // 返信を追加する関数
  Future<void> addReply(Reply reply) async {
    print("返信追加");
    try {
      // 特定のコメントのrepliesサブコレクションに新しい返信を追加
      await comments.doc(reply.commentId).collection('replies').add({
        'content': reply.content,
        'dateTime': reply.dateTime,
        'userName': reply.userName,
        'userId': reply.userId,
      });
      print('Reply added successfully');
    } catch (e) {
      print('Error adding reply: $e');
      throw Exception('Failed to add reply');
    }
  }
}
