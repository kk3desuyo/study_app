import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:study_app/models/studyMaterial.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/widgets/notification/notification_item.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference follows =
      FirebaseFirestore.instance.collection('follows');
  final CollectionReference studySessions =
      FirebaseFirestore.instance.collection('studySession');
  final CollectionReference likes =
      FirebaseFirestore.instance.collection('likes');
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  final CollectionReference notices =
      FirebaseFirestore.instance.collection('notice');

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    auth.User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<List<Map<String, dynamic>>> getFriendNotifications() async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    List<Map<String, dynamic>> notifications = [];

    // Likes
    QuerySnapshot likesSnapshot = await likes
        .where('dailyGoalUserId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
    print("likesSnapshot");
    print(likesSnapshot.docs.length);
    for (var doc in likesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String senderId = data['userId'];
      String? senderName = await getUserName(senderId);
      DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

      notifications.add({
        'title': 'いいね！',
        'message': 'あなたの投稿にいいねがありました。',
        'dateTime': createdAt,
        'type': NotificationType.like,
        'senderName': senderName,
      });
    }

    // Comments
    QuerySnapshot commentsSnapshot = await comments
        .where('dailyGoalUserId', isEqualTo: currentUserId)
        .orderBy('dateTime', descending: true)
        .get();

    for (var doc in commentsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String senderId = data['userId'];
      String? senderName = data['userName'];
      DateTime createdAt = (data['dateTime'] as Timestamp).toDate();

      notifications.add({
        'title': 'コメント',
        'message': 'あなたの投稿にコメントがありました。',
        'dateTime': createdAt,
        'type': NotificationType.comment,
        'senderName': senderName,
      });
    }

    // Follow Requests
    QuerySnapshot followRequestsSnapshot = await follows
        .where('followingUserId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in followRequestsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String senderId = data['followUserId'];
      String? senderName = await getUserName(senderId);
      DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

      notifications.add({
        'title': 'フォローリクエスト',
        'message': '新しいフォローリクエストがあります。',
        'dateTime': createdAt,
        'type': NotificationType.friendRequest,
        'senderName': senderName,
      });
    }

    // Sort notifications by dateTime descending
    notifications.sort((a, b) {
      DateTime dateA = a['dateTime'];
      DateTime dateB = b['dateTime'];
      return dateB.compareTo(dateA);
    });

    return notifications;
  }

  Future<List<Map<String, dynamic>>> getCommunityNotifications() async {
    List<Map<String, dynamic>> notifications = [];

    QuerySnapshot noticesSnapshot =
        await notices.orderBy('createdAt', descending: true).get();

    for (var doc in noticesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
      String content = data['content'];

      notifications.add({
        'title': 'お知らせ',
        'message': content,
        'dateTime': createdAt,
        'type': NotificationType.announcement,
        'senderName': null,
      });
    }

    return notifications;
  }

  Future<void> updateFollowStatus(
      String followingUserId, bool isCurrentlyFollowing) async {
    print(isCurrentlyFollowing);
    String followUserId = getCurrentUserId()!;
    final followQuery = follows
        .where('followUserId', isEqualTo: followUserId)
        .where('followingUserId', isEqualTo: followingUserId)
        .limit(1);

    try {
      final snapshot = await followQuery.get();
      if (!isCurrentlyFollowing && snapshot.docs.isNotEmpty) {
        // フォロー解除
        await snapshot.docs.first.reference.delete();
      } else {
        // フォロー追加
        await follows.add({
          'followUserId': followUserId,
          'followingUserId': followingUserId,
        });
      }
    } catch (e) {
      print("Error updating follow status: $e");
      throw Exception('Failed to update follow status');
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

  Future<List<User>> getFollowingUsers(String userId) async {
    final snapshot = await _firestore
        .collection('follows')
        .where('followingUserId', isEqualTo: userId)
        .get();

    List<User> followingUsers = [];
    for (var doc in snapshot.docs) {
      final userDoc =
          await _firestore.collection('users').doc(doc['followUserId']).get();
      if (userDoc.exists) {
        followingUsers.add(User.fromJson(userDoc.data()!, userDoc.id));
      }
    }
    return followingUsers;
  }

  Future<List<String>> getFollowUserIds(String userId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      List<String> followedUserIds = [];

      QuerySnapshot followsSnapshot =
          await follows.where('followUserId', isEqualTo: userId).get();

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

  Future<List<User>> getFollowUsers(String userId) async {
    List<String> followUserIds = await getFollowUserIds(userId);
    List<User> followUsers = [];

    try {
      for (String userId in followUserIds) {
        User? user = await getUser(userId);
        if (user != null) {
          followUsers.add(user);
        }
      }

      return followUsers;
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

  Future<int> getFollowersCount(String userId) async {
    try {
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('followingUserId', isEqualTo: userId)
          .get();

      return followersSnapshot.docs.length;
    } catch (e) {
      print("Error fetching followers count: $e");
      return 0;
    }
  }

  Future<int> getFollowingCount(String userId) async {
    try {
      QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('followUserId', isEqualTo: userId)
          .get();

      return followingSnapshot.docs.length;
    } catch (e) {
      print("Error fetching following count: $e");
      return 0;
    }
  }

  Future<bool> isFollowing(String userId) async {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      QuerySnapshot followSnapshot = await follows
          .where('followUserId', isEqualTo: currentUserId)
          .where('followingUserId', isEqualTo: userId)
          .limit(1)
          .get();

      return followSnapshot.docs.isNotEmpty;
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
  }
}
