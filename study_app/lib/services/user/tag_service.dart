import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/tag_modale.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/tag.dart';

class TagService {
  TagService();

// Fetch tags for a specific user
  Future<List<Tag>> fetchTagsForUser(String userId) async {
    try {
      // Get the user's tags subcollection
      QuerySnapshot userTagsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tags')
          .get();

      // Build the tag list directly from the user's tags subcollection
      List<Tag> userTags = userTagsSnapshot.docs.map((doc) {
        return Tag(
          id: doc.id,
          name: doc['name'] ?? 'Unknown', // フィールド 'name' が存在しない場合のデフォルト値
          isAchievement:
              doc['isAchievement'] ?? false, // フィールド 'isAchievement' のデフォルト値
        );
      }).toList();

      return userTags;
    } catch (e) {
      print('Error fetching user tags: $e');
      return [];
    }
  }

  // Add selected tags for a user
  Future<void> addTagsForUser(String userId, List<Tag> tags) async {
    try {
      CollectionReference userTagsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tags');

      // Add references to selected tag IDs with additional fields
      for (var tag in tags) {
        await userTagsCollection.doc(tag.id).set({
          'isAchievement': tag.isAchievement,
          'name': tag.name,
        });
      }
    } catch (e) {
      print('Error adding tags for user: $e');
    }
  }

  // Delete all tags for a user
  Future<void> deleteTagsForUser(String userId) async {
    try {
      CollectionReference userTagsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tags');

      QuerySnapshot userTagsSnapshot = await userTagsCollection.get();
      for (var doc in userTagsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting user tags: $e');
    }
  }

  // Fetch all pre-defined tags
  Future<List<Tag>> fetchAllTags() async {
    try {
      QuerySnapshot tagsSnapshot =
          await FirebaseFirestore.instance.collection('tags').get();

      return tagsSnapshot.docs.map((doc) {
        return Tag(
          id: doc.id,
          name: doc['name'],
          isAchievement: doc['isAchievement'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching all tags: $e');
      return [];
    }
  }
}
