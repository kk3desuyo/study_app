// lib/services/user/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/comment_service.dart';
import 'package:study_app/services/like_service.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/widgets/notification/notification_item.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference studySessions =
      FirebaseFirestore.instance.collection('studySession');
  final CollectionReference likes =
      FirebaseFirestore.instance.collection('likes');
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  final CollectionReference notices =
      FirebaseFirestore.instance.collection('notice');
  final CollectionReference followRequests =
      FirebaseFirestore.instance.collection('followRequests');

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    auth.User? user = _auth.currentUser;
    return user?.uid;
    // return user?.uid; // 現在ログインしているユーザーのIDを返す
  }

  Future<bool> checkPassword(String password) async {
    try {
      auth.User? user = _auth.currentUser;
      if (user != null) {
        auth.UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: user.email!,
          password: password,
        );
        return userCredential.user != null;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking password: $e');
      return false;
    }
  }

  Future<void> deleteAccount() async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      // Firestoreからユーザーデータを削除
      await users.doc(currentUserId).delete();

      // Firebase Authenticationからユーザーを削除
      auth.User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }

      print('アカウントが正常に削除されました。');
    } catch (e) {
      print('アカウント削除中にエラーが発生しました: $e');
      throw Exception('アカウントの削除に失敗しました。');
    }
  }

  Future<bool> checkRegistrationStatus() async {
    String? currentUserId = getCurrentUserId(); // ユーザーIDを取得する関数（適切な方法で取得してください）

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userSnapshot.exists && userSnapshot['isRegistering'] == false) {
        print('ユーザーは未登録です。');
        return false;
      } else {
        print('ユーザーは登録済みです。');
        return true;
      }
    } catch (e) {
      print('登録ステータスの確認中にエラーが発生しました: $e');
      return false;
    }
  }

  /// 現在のユーザーの公開設定を取得する関数
  Future<bool> getIsPublic() async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      DocumentSnapshot userDoc = await users.doc(currentUserId).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['isPublic'] ?? false;
      } else {
        throw Exception('ユーザーデータが存在しません。');
      }
    } catch (e) {
      print('Error getting isPublic: $e');
      throw Exception('公開設定の取得に失敗しました。');
    }
  }

  /// 現在のユーザーの公開設定を更新する関数
  Future<void> setIsPublic(bool value) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      await users.doc(currentUserId).update({'isPublic': value});
    } catch (e) {
      print('Error setting isPublic: $e');
      throw Exception('公開設定の更新に失敗しました。');
    }
  }

  /// 特定のuserIdのデイリーゴールといいね情報を取得
  Future<List<Map<String, dynamic>>> getUserDailyGoals(String userId) async {
    try {
      LikeService likeService = LikeService();
      CommentService commentService = CommentService();

      // 指定されたuserIdのデイリーゴールを取得
      QuerySnapshot goalsSnapshot = await _firestore
          .collection('dailyGoals')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> userGoals = [];

      // 現在のユーザーIDを取得（いいね状態の確認に使用）
      String? currentUserId = getCurrentUserId();

      // 現在のユーザーが「いいね」しているdailyGoalIdのセットを取得
      Set<String> likedGoalIds = {};
      if (currentUserId != null) {
        QuerySnapshot likesSnapshot = await _firestore
            .collection('likes')
            .where('userId', isEqualTo: currentUserId)
            .where('dailyGoalUserId', isEqualTo: userId)
            .get();
        likedGoalIds = likesSnapshot.docs
            .map((doc) => doc['dailyGoalId'] as String)
            .toSet();
      }

      for (var doc in goalsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['dailyGoalId'] = doc.id; // ドキュメントIDを追加

        // いいね数を取得して追加
        int likeCount = await likeService.getLikeCount(doc.id);
        data['goodNum'] = likeCount;

        // コメント数を取得して追加
        int commentNum =
            await commentService.getCommentCountByDailyGoalId(doc.id);
        data['commentNum'] = commentNum;

        // 現在のユーザーがいいねしているかどうか
        bool isLikedByCurrentUser = likedGoalIds.contains(doc.id);
        data['isPushFavorite'] = isLikedByCurrentUser;

        // ユーザー情報を追加
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          print(userDoc.id);
          data['user'] = {
            'isPublic': userData['isPublic'] ?? false,
            'id': userDoc.id ?? '',
            'name': userData['name'] ?? '',
            'profileImgUrl': userData['profileImgUrl'] ?? '',
            // 必要に応じて他のユーザー情報も追加
          };
        } else {
          data['user'] = null;
        }

        userGoals.add(data);
      }

      return userGoals;
    } catch (e) {
      print('Error getting user daily goals: $e');
      throw Exception('Failed to get user daily goals');
    }
  }

  /// ブロックユーザーを追加する関数
  Future<void> blockUser(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    if (currentUserId == targetUserId) {
      throw Exception('自分自身をブロックすることはできません。');
    }

    try {
      DocumentReference currentBlockedUserRef =
          users.doc(currentUserId).collection('blockedUsers').doc(targetUserId);
      DocumentReference targetBlockedUserRef = users
          .doc(targetUserId)
          .collection('blockedUsers')
          .doc(currentUserId); // 新規追加

      // ブロックするユーザーのデータを取得
      DocumentSnapshot targetUserSnapshot = await users.doc(targetUserId).get();
      if (!targetUserSnapshot.exists) {
        throw Exception('ブロックしようとしているユーザーが存在しません。');
      }

      // トランザクションを使用して一貫性を保つ
      await _firestore.runTransaction((transaction) async {
        // ブロックユーザーを追加
        transaction.set(currentBlockedUserRef, {
          'blockedAt': FieldValue.serverTimestamp(),
        });

        // ターゲットユーザーにもブロッカーを追加
        transaction.set(targetBlockedUserRef, {
          'blockedAt': FieldValue.serverTimestamp(),
        });

        // フォロー関係を解除

        // currentUserがtargetUserをフォローしている場合は解除
        DocumentReference currentFollowingRef =
            users.doc(currentUserId).collection('following').doc(targetUserId);
        transaction.delete(currentFollowingRef);

        // targetUserがcurrentUserをフォローしている場合は解除
        DocumentReference targetFollowingRef =
            users.doc(targetUserId).collection('following').doc(currentUserId);
        transaction.delete(targetFollowingRef);

        // currentUserがtargetUserからフォローされている場合は解除
        DocumentReference currentFollowerRef =
            users.doc(currentUserId).collection('followers').doc(targetUserId);
        transaction.delete(currentFollowerRef);

        // targetUserがcurrentUserからフォローされている場合は解除
        DocumentReference targetFollowerRef =
            users.doc(targetUserId).collection('followers').doc(currentUserId);
        transaction.delete(targetFollowerRef);
      });

      print('ユーザーをブロックしました。');
    } catch (e) {
      print('ユーザーをブロック中にエラーが発生しました: $e');
      throw Exception('ユーザーのブロックに失敗しました。');
    }
  }

  /// ブロックユーザーを解除する関数
  Future<void> unblockUser(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      DocumentReference blockedUserRef =
          users.doc(currentUserId).collection('blockedUsers').doc(targetUserId);

      await blockedUserRef.delete();
      DocumentReference targetUserRef =
          users.doc(targetUserId).collection('blockedUsers').doc(currentUserId);

      await targetUserRef.delete();

      print('ユーザーのブロックを解除しました。');
    } catch (e) {
      print('ユーザーのブロック解除中にエラーが発生しました: $e');
      throw Exception('ユーザーのブロック解除に失敗しました。');
    }
  }

  /// 指定されたユーザーがブロックされているか確認する関数
  Future<bool> isUserBlocked(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      DocumentSnapshot blockedUserSnapshot = await users
          .doc(currentUserId)
          .collection('blockedUsers')
          .doc(targetUserId)
          .get();

      return blockedUserSnapshot.exists;
    } catch (e) {
      print('ブロック状態の確認中にエラーが発生しました: $e');
      throw Exception('ブロック状態の確認に失敗しました。');
    }
  }

  /// 現在のユーザーがブロックしているユーザーのリストを取得する関数
  Future<List<User>> getBlockedUsersList() async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      QuerySnapshot blockedUsersSnapshot =
          await users.doc(currentUserId).collection('blockedUsers').get();

      List<User> blockedUsers = [];

      for (var doc in blockedUsersSnapshot.docs) {
        String blockedUserId = doc.id;
        User? user = await getUser(blockedUserId);
        if (user != null) {
          blockedUsers.add(user);
        }
      }

      return blockedUsers;
    } catch (e) {
      print('ブロックユーザーのリスト取得中にエラーが発生しました: $e');
      throw Exception('ブロックユーザーのリスト取得に失敗しました。');
    }
  }

  Future<String?> getUserProfileImage(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['profileImgUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user profile image: $e');
      throw Exception('Failed to get user profile image');
    }
  }

  /// 現在のユーザーがフォローしているユーザーのリストを取得
  Future<List<User>> getFollowingUsersList(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();

    List<User> followingUsers = [];
    for (var doc in snapshot.docs) {
      final userDoc = await _firestore.collection('users').doc(doc.id).get();
      if (userDoc.exists) {
        followingUsers.add(User.fromJson(userDoc.data()!, userDoc.id));
      }
    }
    return followingUsers;
  }

  Future<List<User>> getFollowUsersList(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();

    List<User> followingUsers = [];
    for (var doc in snapshot.docs) {
      final userDoc = await _firestore.collection('users').doc(doc.id).get();
      if (userDoc.exists) {
        followingUsers.add(User.fromJson(userDoc.data()!, userDoc.id));
      }
    }
    return followingUsers;
  }

  /// 現在のユーザーがフォローしているユーザーのIDリストを取得
  Future<List<String>> getFollowingUserIds(String userId) async {
    try {
      List<String> followingUserIds = [];

      QuerySnapshot followsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      for (var doc in followsSnapshot.docs) {
        String followingUserId = doc.id; // ドキュメントIDがユーザーID
        followingUserIds.add(followingUserId);
      }

      return followingUserIds;
    } catch (e) {
      print('Error getting followed users: $e');
      throw Exception('Failed to get followed users');
    }
  }

  /// 現在のユーザーがフォローしているユーザーの詳細リストを取得
  Future<List<User>> getFollowingUsersDetails(String userId) async {
    List<String> followingUserIds = await getFollowingUserIds(userId);
    print("followingUserIds: ${followingUserIds.length}");
    List<User> followingUsers = [];

    try {
      for (String userId in followingUserIds) {
        User? user = await getUser(userId);
        if (user != null) {
          followingUsers.add(user);
        }
      }

      return followingUsers;
    } catch (e) {
      print('Error getting followed user data: $e');
      throw Exception('Failed to get followed user data');
    }
  }

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

  Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['name'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user name: $e');
      throw Exception('Failed to get user name');
    }
  }

  /// 指定されたユーザーのフォロワー数を取得
  Future<int> getFollowersCount(String userId) async {
    try {
      QuerySnapshot followersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      return followersSnapshot.docs.length;
    } catch (e) {
      print("Error fetching followers count: $e");
      return 0;
    }
  }

  /// 指定されたユーザーがフォローしているユーザー数を取得
  Future<int> getFollowingCount(String userId) async {
    try {
      QuerySnapshot followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      return followingSnapshot.docs.length;
    } catch (e) {
      print("Error fetching following count: $e");
      return 0;
    }
  }

  /// 現在のユーザーが指定されたユーザーをフォローしているか確認
  Future<bool> isUserFollowing(String targetUserId) async {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      // targetUserId の followers サブコレクションに currentUserId が存在するか確認
      DocumentSnapshot followDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .get();

      return followDoc.exists;
    } catch (e) {
      print('Error checking if following user: $e');
      throw Exception('Failed to check if following user');
    }
  }

  final CollectionReference tags =
      FirebaseFirestore.instance.collection('tags');

  Future<List<Map<String, dynamic>>> fetchUserTags(String userId) async {
    try {
      QuerySnapshot tagsSnapshot =
          await tags.where('userId', isEqualTo: userId).get();

      List<Map<String, dynamic>> userTags = tagsSnapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'isAchievement': doc['isAchievement'] as bool,
        };
      }).toList();

      return userTags;
    } catch (e) {
      print('Error fetching user tags: $e');
      return [];
    }
  }

  Future<void> addUser() async {
    try {
      String userId = getCurrentUserId() ?? '';
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Check if the user document already exists
        DocumentSnapshot userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          // Create a new user document if it does not exist
          Map<String, dynamic> userData = {'isRegistering': false};

          transaction.set(userDoc, userData);

          print("User added successfully.");
        } else {
          print("User already exists.");
        }
      });
    } catch (e) {
      print('Error adding user: $e');
      throw Exception('Failed to add user');
    }
  }

  Future<void> firstUserProfileAdd({
    String? name,
    String profileImgUrl = "",
    String? oneWord,
    List<Tag>? newTags,
    bool? isPublic = false,
  }) async {
    String? userId = getCurrentUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      Map<String, dynamic> profileUpdates = {};
      if (name != null) profileUpdates['name'] = name;

      profileUpdates['profileImgUrl'] = profileImgUrl;
      if (oneWord != null) profileUpdates['oneWord'] = oneWord;
      profileUpdates['isRegistering'] = true;
      profileUpdates['isPublic'] = isPublic;
      profileUpdates['createdAt'] = FieldValue.serverTimestamp();

      if (profileUpdates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(profileUpdates);
      }

      if (newTags != null) {
        CollectionReference tagsCollection =
            FirebaseFirestore.instance.collection('tags');

        QuerySnapshot existingTagsSnapshot =
            await tagsCollection.where('userId', isEqualTo: userId).get();

        for (var doc in existingTagsSnapshot.docs) {
          await doc.reference.delete();
        }

        for (var tag in newTags) {
          await tagsCollection.add({
            'userId': userId,
            'name': tag.name,
            'isAchievement': tag.isAchievement,
          });
        }
      }

      print("User profile updated successfully.");
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileImgUrl,
    String? oneWord,
    List<Tag>? newTags,
  }) async {
    String? userId = getCurrentUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      Map<String, dynamic> profileUpdates = {};
      if (name != null) profileUpdates['name'] = name;
      if (profileImgUrl != null)
        profileUpdates['profileImgUrl'] = profileImgUrl;
      if (oneWord != null) profileUpdates['oneWord'] = oneWord;

      if (profileUpdates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(profileUpdates);
      }

      if (newTags != null) {
        CollectionReference tagsCollection =
            FirebaseFirestore.instance.collection('tags');

        QuerySnapshot existingTagsSnapshot =
            await tagsCollection.where('userId', isEqualTo: userId).get();

        for (var doc in existingTagsSnapshot.docs) {
          await doc.reference.delete();
        }

        for (var tag in newTags) {
          await tagsCollection.add({
            'userId': userId,
            'name': tag.name,
            'isAchievement': tag.isAchievement,
          });
        }
      }

      print("User profile updated successfully.");
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  /// ユーザーが今日勉強した教材とその勉強時間を取得する関数
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
  }

  /// コメントを追加し、通知を作成するメソッド
  Future<void> addCommentWithNotification({
    required String dailyGoalId,
    required String content,
  }) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    try {
      // コメントデータを準備
      Map<String, dynamic> commentData = {
        'content': content,
        'dailyGoalId': dailyGoalId,
        'dateTime': FieldValue.serverTimestamp(),
        'userId': currentUserId,
        'userName': await getUserName(currentUserId) ?? 'Unknown',
      };

      // コメントを追加
      DocumentReference commentRef =
          await _firestore.collection('comments').add(commentData);

      print('コメントが追加されました。ID: ${commentRef.id}');

      // Daily Goalのオーナーを取得
      DocumentSnapshot dailyGoalSnap =
          await _firestore.collection('dailyGoals').doc(dailyGoalId).get();
      if (!dailyGoalSnap.exists) {
        throw Exception('指定されたDaily Goalが存在しません。');
      }

      String ownerId = dailyGoalSnap['userId'];
      if (ownerId == currentUserId) {
        // 自分自身のDaily Goalにコメントした場合、通知は不要
        return;
      }

      // オーナーの名前を取得
      String ownerName = await getUserName(ownerId) ?? 'Unknown';

      // 通知データを準備
      Map<String, dynamic> notificationData = {
        'title': '新しいコメント',
        'message': '${commentData['userName']} があなたのDaily Goalにコメントしました。',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'new_comment',
        'senderName': commentData['userName'],
        'senderId': currentUserId,
        'dailyGoalId': dailyGoalId,
        'commentId': commentRef.id,
      };

      // 通知を追加
      await _firestore
          .collection('users')
          .doc(ownerId)
          .collection('notifications')
          .add(notificationData);

      print('通知が作成されました。');
    } catch (e) {
      print('コメント追加中にエラーが発生しました: $e');
      throw Exception('コメントの追加に失敗しました。');
    }
  }

  /// フォローリクエストの状態を取得
  Future<String> getFollowRequestStatus(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // 自分から相手へのリクエストを確認
    DocumentSnapshot sentRequest = await _firestore
        .collection('followRequests')
        .doc('$currentUserId\_$targetUserId')
        .get();
    if (sentRequest.exists) {
      return 'requested_by_current_user';
    }

    // 相手から自分へのリクエストを確認
    DocumentSnapshot receivedRequest = await _firestore
        .collection('followRequests')
        .doc('$targetUserId\_$currentUserId')
        .get();
    if (receivedRequest.exists) {
      return 'requested_by_target_user';
    }

    return 'no_request';
  }

  /// フォローリクエストを送信
  Future<void> sendFollowRequest(String targetUserId) async {
    print("フォローリクエストを送信します。");
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // 既にフォローしているかチェック
    bool alreadyFollowing = await isUserFollowing(targetUserId);
    if (alreadyFollowing) {
      throw Exception('既にフォローしています。');
    }

    // フォローリクエストの状態を確認
    String requestStatus = await getFollowRequestStatus(targetUserId);
    if (requestStatus == 'requested_by_current_user') {
      throw Exception('既にフォローリクエストを送信済みです。');
    } else if (requestStatus == 'requested_by_target_user') {
      // 相手からリクエストがある場合は承認する
      await approveFollowRequest(targetUserId);
      return;
    }

    // ターゲットユーザーのisPublicフィールドを確認
    DocumentSnapshot targetUserDoc =
        await _firestore.collection('users').doc(targetUserId).get();
    if (targetUserDoc.exists && targetUserDoc.data() != null) {
      Map<String, dynamic> targetUserData =
          targetUserDoc.data() as Map<String, dynamic>;
      bool isPublic = targetUserData['isPublic'] ?? false;

      if (isPublic) {
        // ユーザーが公開アカウントの場合、直接フォロー
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .set({
          'userId': targetUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId)
            .set({
          'userId': currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 通知を作成
        String senderName = await getUserName(currentUserId) ?? 'Unknown';
        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('notifications')
            .add({
          'title': '新しいフォロワー',
          'message': '$senderName があなたをフォローしました。',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'new_follower',
          'senderName': senderName,
          'senderId': currentUserId,
        });

        return;
      }
    }

    // フォローリクエストを作成
    await _firestore
        .collection('followRequests')
        .doc('$currentUserId\_$targetUserId')
        .set({
      'fromUserId': currentUserId,
      'toUserId': targetUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("フォローリクエストを送信しました。");
    // 通知を作成
    String senderName = await getUserName(currentUserId) ?? 'Unknown';
    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .add({
      'title': 'フォローリクエスト',
      'message': '$senderName からフォローリクエストが届きました。',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'friend_request',
      'senderName': senderName,
      'senderId': currentUserId,
    });
  }

  /// フォローリクエストをキャンセル
  Future<void> cancelFollowRequest(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // フォローリクエストの状態を確認
    String requestStatus = await getFollowRequestStatus(targetUserId);
    if (requestStatus != 'requested_by_current_user') {
      throw Exception('フォローリクエストを送信していません。');
    }

    // フォローリクエストを削除
    await _firestore
        .collection('followRequests')
        .doc('$currentUserId\_$targetUserId')
        .delete();

    print('フォローリクエストをキャンセルしました。');
    // 通知を削除する場合は、通知IDを管理する必要があります
    // ここでは通知を削除しない場合もありますが、必要に応じて実装してください
  }

  /// フォローリクエストを承認（相手のフォローのみを受け入れる）
  Future<void> approveFollowRequest(String targetUserId) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // トランザクションを使用して一貫性を保つ
    await _firestore.runTransaction((transaction) async {
      DocumentReference sentRequestRef = _firestore
          .collection('followRequests')
          .doc('$targetUserId\_$currentUserId');

      DocumentSnapshot sentRequestSnap = await transaction.get(sentRequestRef);
      if (!sentRequestSnap.exists) {
        throw Exception('承認すべきフォローリクエストがありません。');
      }

      // 現在のユーザーの followers にリクエスト送信ユーザーを追加
      DocumentReference currentFollowersRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('followers')
          .doc(targetUserId);

      transaction.set(currentFollowersRef, {
        'userId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // リクエスト送信ユーザーの following に現在のユーザーを追加
      DocumentReference targetFollowingRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('following')
          .doc(currentUserId);

      transaction.set(targetFollowingRef, {
        'userId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 通知を作成
      String senderName = await getUserName(currentUserId) ?? 'Unknown';
      DocumentReference notificationRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .doc();

      transaction.set(notificationRef, {
        'title': 'フォローリクエスト承認',
        'message': '$senderName のフォローリクエストが承認されました。',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'friend_request_accepted',
        'senderName': senderName,
        'senderId': currentUserId,
      });

      // フォローリクエストを削除
      transaction.delete(sentRequestRef);
    });
    print('フォローリクエストを承認しました。');
  }

  /// フォロー状態を更新（フォロー/アンフォロー）
  Future<void> updateFollowStatus(String targetUserId, bool follow) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    if (follow) {
      // フォローする場合
      bool alreadyFollowing = await isUserFollowing(targetUserId);
      if (alreadyFollowing) {
        throw Exception('既にフォローしています。');
      }

      // ターゲットユーザーのisPublicフィールドを確認
      DocumentSnapshot targetUserDoc =
          await _firestore.collection('users').doc(targetUserId).get();
      if (targetUserDoc.exists && targetUserDoc.data() != null) {
        Map<String, dynamic> targetUserData =
            targetUserDoc.data() as Map<String, dynamic>;
        bool isPublic = targetUserData['isPublic'] ?? false;

        if (isPublic) {
          // ユーザーが公開アカウントの場合、直接フォロー
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('following')
              .doc(targetUserId)
              .set({
            'userId': targetUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });

          await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('followers')
              .doc(currentUserId)
              .set({
            'userId': currentUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // 通知を作成
          String senderName = await getUserName(currentUserId) ?? 'Unknown';
          await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('notifications')
              .add({
            'title': '新しいフォロワー',
            'message': '$senderName があなたをフォローしました。',
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'new_follower',
            'senderName': senderName,
            'senderId': currentUserId,
          });

          return;
        }
      }

      // フォローリクエストを送信
      await sendFollowRequest(targetUserId);
    } else {
      // フォローを解除する場合
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();

      // 通知を削除（オプション）
      // 通知を削除する場合は、通知IDを管理する必要があります
      // ここでは通知を削除しない場合もありますが、必要に応じて実装してください
    }
  }

  // /// ユーザーの友達通知をリアルタイムで取得するストリーム
  // Stream<List<Map<String, dynamic>>> getFriendNotifications(String userId) {
  //   return _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('notifications')
  //       .where('type', isEqualTo: 'friend_request')
  //       .orderBy('dateTime', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) {
  //             return {
  //               'title': doc['title'],
  //               'message': doc['message'],
  //               'dateTime': (doc['dateTime'] as Timestamp).toDate(),
  //               'type': doc['type'],
  //               'senderName': doc['senderName'],
  //               'senderId': doc['senderId'],
  //             };
  //           }).toList());
  // }

  // /// ユーザーのコミュニティ通知をリアルタイムで取得するストリーム
  // Stream<List<Map<String, dynamic>>> getCommunityNotifications(String userId) {
  //   return _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('notifications')
  //       .where('type', isEqualTo: 'community_announcement')
  //       .orderBy('dateTime', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) {
  //             return {
  //               'title': doc['title'],
  //               'message': doc['message'],
  //               'dateTime': (doc['dateTime'] as Timestamp).toDate(),
  //               'type': doc['type'],
  //               'senderName': doc['senderName'],
  //             };
  //           }).toList());
  // }

  Stream<List<Map<String, dynamic>>> getAllNotifications(String userId) {
    print('Getting all notifications for user $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      snapshot.docs.forEach((doc) {
        print('Notification document: ${doc.data()}');
      });
      return snapshot.docs.map((doc) {
        print('Notification Type: ${doc['type']}');

        // ドキュメントデータを安全に取得
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return {
          'title': data['title'] ?? 'いいね', // デフォルト値を設定
          'message': data['message'] ?? 'No Message',
          'dateTime': data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(), // デフォルト値を設定
          'type': data['type'] ?? 'other',
          'senderName': data['senderName'] ?? '', // デフォルト値を設定
          'senderId': data['senderId'] ?? '',
          'dailyGoalId': data.containsKey('dailyGoalId')
              ? data['dailyGoalId']
              : '', // 存在チェック
        };
      }).toList();
    });
  }

  /// notice コレクションから通知を取得するメソッド
  Stream<List<Map<String, dynamic>>> getNotices() {
    return _firestore
        .collection('notice')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return {
                'title': data['title'] ?? 'お知らせ', // デフォルトのタイトル
                'message': data['message'] ?? 'メッセージがありません', // デフォルト値を設定
                'dateTime': (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(), // デフォルト値を設定
                'type': 'notice', // 固定のタイプを設定
                'senderName': '', // 空文字列を設定
                'senderId': '', // 空文字列を設定
                'dailyGoalId': '', // 空文字列を設定
              };
            }).toList());
  }

  /// Real-time stream for follow requests for the given user
  Stream<List<Map<String, dynamic>>> getFollowRequestNotifications(
      String userId) {
    return _firestore
        .collection('followRequests')
        .where('toUserId', isEqualTo: userId) // Only fetch requests to the user
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'fromUserId': doc['fromUserId'],
                'toUserId': doc['toUserId'],
                'timestamp': (doc['timestamp'] as Timestamp).toDate(),
                'type': 'friend_request',
              };
            }).toList());
  }

  /// Real-time stream for new followers for the given user
  Stream<List<Map<String, dynamic>>> getFollowerNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'followerUserId': doc.id, // Follower's user ID
                'timestamp': (doc['timestamp'] as Timestamp).toDate(),
                'type': 'new_follower',
              };
            }).toList());
  }
}
