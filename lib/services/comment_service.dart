// lib/services/comment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/comment.dart';
import 'package:study_app/models/reply.dart';
import 'package:study_app/services/user/user_service.dart';

class CommentService {
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = UserService(); // UserServiceのインスタンスを追加

  // コメントを消去する関数
  Future<void> deleteComment(String commentId) async {
    try {
      // コメントを削除
      await comments.doc(commentId).delete();
      print('Comment deleted successfully');
    } catch (e) {
      print('Error deleting comment: $e');
      throw Exception('Failed to delete comment');
    }
  }

  // コメントをdailyGoalIdに基づいて取得する関数（ページネーション対応）
  Future<List<Comment>> getCommentsByDailyGoalId(
    String dailyGoalId, {
    int limit = 10,
    DocumentSnapshot? lastDocument, // ページネーションのために追加
  }) async {
    try {
      // 現在のユーザーIDを取得
      String? currentUserId = userService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('ユーザーがログインしていません。');
      }

      // ブロックされているユーザーのIDリストを取得
      List<String> blockedUserIds = (await userService.getBlockedUsersList())
          .map((user) => user.id)
          .toList();

      print("blockedUserIds");

      Query query = _firestore
          .collection('comments')
          .where('dailyGoalId', isEqualTo: dailyGoalId)
          .orderBy('dateTime', descending: true) // 日付でソート
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      querySnapshot.docs.forEach((doc) {
        print(doc.data());
      });
      // ブロックされていないユーザーのコメントのみをリスト化
      List<QueryDocumentSnapshot> filteredComments = querySnapshot.docs
          .where((doc) => !blockedUserIds.contains(doc['userId']))
          .toList();
      List<Comment> commentsList = [];
      Set<String> userIds = {};

      // コメントからuserIdを収集
      for (var doc in filteredComments) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? userId = data['userId'] as String?;
        if (userId == null) {
          print('Warning: userId is null for document ${doc.id}');
          continue;
        }

        // ブロックされているユーザーのコメントを除外
        if (blockedUserIds.contains(userId)) {
          continue;
        }

        userIds.add(userId);
      }

      // ユーザー情報を一括取得
      Map<String, String> userIdToNameMap = {};
      if (userIds.isNotEmpty) {
        List<String> userIdList = userIds.toList();
        int batchSize = 10; // FirestoreのwhereInクエリの制限
        for (int i = 0; i < userIdList.length; i += batchSize) {
          List<String> batchUserIds =
              userIdList.skip(i).take(batchSize).toList();

          QuerySnapshot userSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: batchUserIds)
              .get();

          for (var userDoc in userSnapshot.docs) {
            String userId = userDoc.id;
            String userName = userDoc['name'] ?? 'Unknown';
            userIdToNameMap[userId] = userName;
          }
        }
      }

      // コメントリストを構築
      for (var doc in filteredComments) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String userId = data['userId'];
        String userName = userIdToNameMap[userId] ?? 'Unknown';
        data['userName'] = userName;

        Comment comment =
            Comment.fromFirestore(doc.id, data, documentSnapshot: doc);
        commentsList.add(comment);
      }

      return commentsList;
    } catch (e) {
      print('Error getting comments: $e');
      throw Exception('Failed to get comments');
    }
  }

  // dailyGoalIdに関連するすべての返信を取得する関数
  Future<List<Reply>> getRepliesForDailyGoal(String dailyGoalId) async {
    try {
      // 現在のユーザーIDを取得
      String? currentUserId = userService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('ユーザーがログインしていません。');
      }

      // ブロックされているユーザーのIDリストを取得
      List<String> blockedUserIds = (await userService.getBlockedUsersList())
          .map((user) => user.id)
          .toList();

      print("blockedUserIds");
      print(blockedUserIds[0]);

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // dailyGoalIdに一致するcommentsコレクションのドキュメントを取得
      QuerySnapshot commentsSnapshot = await firestore
          .collection('comments')
          .where('dailyGoalId', isEqualTo: dailyGoalId)
          .get();

      List<Reply> allReplies = [];
      Set<String> userIds = {};

      // 各コメントドキュメントのrepliesサブコレクションから返信を取得
      for (var commentDoc in commentsSnapshot.docs) {
        String commentId = commentDoc.id;
        QuerySnapshot repliesSnapshot =
            await commentDoc.reference.collection('replies').get();

        for (var replyDoc in repliesSnapshot.docs) {
          Map<String, dynamic> data = replyDoc.data() as Map<String, dynamic>;
          String userId = data['userId'];

          // ブロックされているユーザーの返信を除外
          if (blockedUserIds.contains(userId)) {
            continue;
          }

          userIds.add(userId);
          allReplies.add(Reply.fromFirestore(replyDoc.id, data, commentId));
        }
      }

      // ユーザー情報を一括取得
      Map<String, String> userIdToNameMap = {};
      if (userIds.isNotEmpty) {
        List<String> userIdList = userIds.toList();
        int batchSize = 10; // FirestoreのwhereInクエリの制限
        for (int i = 0; i < userIdList.length; i += batchSize) {
          List<String> batchUserIds =
              userIdList.skip(i).take(batchSize).toList();

          QuerySnapshot userSnapshot = await firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: batchUserIds)
              .get();

          for (var userDoc in userSnapshot.docs) {
            String userId = userDoc.id;
            String userName = userDoc['name'] ?? 'Unknown';
            userIdToNameMap[userId] = userName;
          }
        }
      }

      // 返信リストにuserNameを追加
      for (var reply in allReplies) {
        String userId = reply.userId;
        String userName = userIdToNameMap[userId] ?? 'Unknown';
        reply.userName = userName;
      }

      return allReplies;
    } catch (e) {
      print('Error getting replies: $e');
      throw Exception('Failed to get replies');
    }
  }

  // dailyGoalIdに基づいてコメント数を取得する関数
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
        'userId': comment.userId,
      });
      print('Comment added successfully: ${comment.content}');
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
        'userId': reply.userId,
      });
      print('Reply added successfully');
    } catch (e) {
      print('Error adding reply: $e');
      throw Exception('Failed to add reply');
    }
  }
}
