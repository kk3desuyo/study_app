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
        .doc('isStudyTimeVisible') // 実際のドキュメント名に変更
        .snapshots();
  }

  Future<void> updateAppSettings(String docId, AppSettings settings) async {
    await appSettingsCollection.doc(docId).update(settings.toJson());
  }

  Future<void> deleteAppSettings(String docId) async {
    await appSettingsCollection.doc(docId).delete();
  }

  // getAppSettingsStreamV2メソッドを定義
  Stream<DocumentSnapshot> getAppSettingsStreamV2() {
    return FirebaseFirestore.instance
        .collection('app_settings')
        .doc('settings')
        .snapshots();
  }
}
