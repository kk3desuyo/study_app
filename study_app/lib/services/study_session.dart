import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/study_session.dart';

class StudySessionService {
  final CollectionReference studySessionCollection =
      FirebaseFirestore.instance.collection('studySession');

  // StudySessionを追加する関数
  Future<void> addStudySession(StudySession session) async {
    try {
      await studySessionCollection.add(session.toFirestore());
      print('StudySession added successfully');
    } catch (e) {
      print('Error adding StudySession: $e');
      throw Exception('Failed to add StudySession');
    }
  }

  // userIdに基づいてStudySessionを取得する関数
  Future<List<StudySession>> getStudySessionsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await studySessionCollection.where('userId', isEqualTo: userId).get();

      List<StudySession> sessions = querySnapshot.docs.map((doc) {
        return StudySession.fromFirestore(doc);
      }).toList();

      return sessions;
    } catch (e) {
      print('Error getting StudySessions: $e');
      throw Exception('Failed to get StudySessions');
    }
  }

  // studySessionIdに基づいて特定のStudySessionを取得する関数
  Future<StudySession?> getStudySessionById(String studySessionId) async {
    try {
      DocumentSnapshot doc =
          await studySessionCollection.doc(studySessionId).get();

      if (doc.exists) {
        return StudySession.fromFirestore(doc);
      } else {
        print('StudySession not found');
        return null;
      }
    } catch (e) {
      print('Error getting StudySession: $e');
      throw Exception('Failed to get StudySession');
    }
  }

  // StudySessionを更新する関数
  Future<void> updateStudySession(
      String studySessionId, StudySession session) async {
    try {
      await studySessionCollection
          .doc(studySessionId)
          .update(session.toFirestore());
      print('StudySession updated successfully');
    } catch (e) {
      print('Error updating StudySession: $e');
      throw Exception('Failed to update StudySession');
    }
  }

  // StudySessionを削除する関数
  Future<void> deleteStudySession(String studySessionId) async {
    try {
      await studySessionCollection.doc(studySessionId).delete();
      print('StudySession deleted successfully');
    } catch (e) {
      print('Error deleting StudySession: $e');
      throw Exception('Failed to delete StudySession');
    }
  }
}
