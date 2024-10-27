import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/services/like_service.dart'; // LikeServiceをインポート

class DailyGoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getFollowedUserDailyGoals() async {
    UserService userService = UserService();
    LikeService likeService = LikeService();
    CommentService commentService = CommentService();
    // LikeServiceのインスタンスを作成
    String? currentUserId = userService.getCurrentUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    List<Map<String, dynamic>> followedUserGoals = [];

    // 1. フォロー中のユーザーIDを取得
    List<String> followedUserIds = await userService.getFollowedUserIds();

    // 2. フォロー中のユーザーの DailyGoals とユーザー情報を取得
    for (var followingUserId in followedUserIds) {
      // フォロー中のユーザー情報を取得
      User? user = await userService.getUser(followingUserId);

      if (user != null) {
        // 3. フォロー中のユーザーの DailyGoal を取得
        QuerySnapshot dailyGoalsSnapshot = await _firestore
            .collection('DailyGoals')
            .where('userId', isEqualTo: followingUserId)
            .get();

        // ユーザー情報と DailyGoals を結合してリストに追加
        for (var goalDoc in dailyGoalsSnapshot.docs) {
          Map<String, dynamic> goalData =
              goalDoc.data() as Map<String, dynamic>;
          print("aaaa");
          print(goalDoc.id);
          // ドキュメントIDを追加
          goalData['dailyGoalId'] = goalDoc.id;

          // いいね数を取得して追加
          int likeCount = await likeService.getLikeCount(goalDoc.id);
          goalData['goodNum'] = likeCount;

          int commentNum =
              await commentService.getCommentCountByDailyGoalId(goalDoc.id);
          goalData['commentNum'] = commentNum;

          bool isLikedByCurrentUser =
              await likeService.isLikedByCurrentUser(goalDoc.id);
          goalData['isPushFavorite'] = isLikedByCurrentUser;

          // ユーザー情報を追加
          goalData['user'] = {
            'id': user.id,
            'name': user.name,
            'profileImgUrl': user.profileImgUrl,
            // 必要に応じて他のユーザー情報も追加
          };

          followedUserGoals.add(goalData);
        }
      }
    }

    return followedUserGoals;
  }
}
