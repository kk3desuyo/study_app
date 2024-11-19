import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/tag.dart';

class TagService {
  // Constructor
  TagService();

  // Method to add a tag
  Future<List<Map<String, dynamic>>> fetchUserTags(String userId) async {
    try {
      List<Tag> userTags = await fetchTagsForUser(userId);

      return userTags.map((tag) {
        return {
          'name': tag.name,
          'isAchievement': tag.isAchievement,
        };
      }).toList();
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
    UserService userService = UserService();
    String? userId = userService.getCurrentUserId();

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
        await deleteTagsForUser(userId);
        await addTagsForUser(userId, newTags);
      }

      print("User profile updated successfully.");
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<void> firstUserProfileAdd({
    String? name,
    String profileImgUrl = "",
    String? oneWord,
    List<Tag>? newTags,
    bool? isPublic = false,
  }) async {
    UserService userService = UserService();
    String? userId = userService.getCurrentUserId();

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
        await deleteTagsForUser(userId);
        await addTagsForUser(userId, newTags);
      }

      print("User profile updated successfully.");
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  } // タグを取得する関数

  Future<List<Tag>> fetchTagsForUser(String userId) async {
    try {
      QuerySnapshot tagsSnapshot = await FirebaseFirestore.instance
          .collection('tags')
          .where('userId', isEqualTo: userId)
          .get();

      List<Tag> userTags = tagsSnapshot.docs.map((doc) {
        return Tag(
          name: doc['name'],
          isAchievement: doc['isAchievement'],
        );
      }).toList();

      return userTags;
    } catch (e) {
      print('Error fetching user tags: $e');
      return [];
    }
  }

// ユーザーの既存のタグを削除する関数
  Future<void> deleteTagsForUser(String userId) async {
    CollectionReference tagsCollection =
        FirebaseFirestore.instance.collection('tags');

    QuerySnapshot existingTagsSnapshot =
        await tagsCollection.where('userId', isEqualTo: userId).get();

    for (var doc in existingTagsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

// 新しいタグを追加する関数
  Future<void> addTagsForUser(String userId, List<Tag> newTags) async {
    CollectionReference tagsCollection =
        FirebaseFirestore.instance.collection('tags');

    for (var tag in newTags) {
      await tagsCollection.add({
        'userId': userId,
        'name': tag.name,
        'isAchievement': tag.isAchievement,
      });
    }
  }
}
