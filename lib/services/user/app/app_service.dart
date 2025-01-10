import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/app/app_setting.dart';

class AppService {
  final CollectionReference appSettingsCollection =
      FirebaseFirestore.instance.collection('AppSettings');

  Future<void> addAppSettings(AppSettings settings) async {
    await appSettingsCollection.add(settings.toJson());
  }

  Stream<DocumentSnapshot> getAppSettingsStream() {
    return FirebaseFirestore.instance
        .collection('AppSettings')
        .doc('studyTimeVisible') // 正しいドキュメント名を使用
        .snapshots();
  }

  Future<void> updateAppSettings(String docId, AppSettings settings) async {
    await appSettingsCollection.doc(docId).update(settings.toJson());
  }

  Future<void> deleteAppSettings(String docId) async {
    await appSettingsCollection.doc(docId).delete();
  }

  Future<bool?> getIsStudyTimeVisible() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('AppSettings')
          .doc('studyTimeVisible')
          .get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        return data?['isStudyTimeVisible'] as bool?;
      }
    } catch (e) {
      print("Error fetching isStudyTimeVisible: $e");
    }
    return null;
  }

  Future<DateTime?> getVisibilityTime() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('AppSettings')
          .doc('studyTimeVisible')
          .get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        final timestamp = data?['visibilityTime'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      print("Error fetching visibilityTime: $e");
    }
    return null;
  }
}
