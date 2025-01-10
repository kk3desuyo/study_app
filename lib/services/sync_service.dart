import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class SyncService {
  final _studyBox = Hive.box('studyRecords');

  void startSyncTimer() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      await syncStudyRecords();
    });
  }

  Future<void> syncStudyRecords() async {
    // FirestoreからvisibilityTimeを取得
    final snapshot = await FirebaseFirestore.instance
        .collection('AppSettings')
        .doc('studyTimeVisible')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      final Timestamp visibilityTime = data?['visibilityTime'];
      final DateTime visibilityDateTime = visibilityTime.toDate();

      // visibilityTimeを過ぎた場合、ローカルデータをFirestoreに送信
      if (DateTime.now().isAfter(visibilityDateTime)) {
        final records = _studyBox.values.toList();
        for (var record in records) {
          await FirebaseFirestore.instance
              .collection('studyRecords')
              .add(record);
        }
        // ローカルデータベースをクリア
        await _studyBox.clear();
      }
    }
  }
}
