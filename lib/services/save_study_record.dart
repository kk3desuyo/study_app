import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyRecordService {
  final _studyBox = Hive.box('studyRecords');

  Future<void> saveStudyRecordToLocal(Map<String, dynamic> record) async {
    // ローカルデータベースに保存
    await _studyBox.add(record);
  }

  Future<void> saveStudyRecord(Map<String, dynamic> record) async {
    // FirestoreからvisibilityTimeを取得
    final snapshot = await FirebaseFirestore.instance
        .collection('AppSettings')
        .doc('studyTimeVisible')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      final Timestamp visibilityTime = data?['visibilityTime'];
      final DateTime visibilityDateTime = visibilityTime.toDate();

      // 現在時刻と比較
      if (DateTime.now().isBefore(visibilityDateTime)) {
        // visibilityTime前: ローカルに保存
        await saveStudyRecordToLocal(record);
      } else {
        // visibilityTime後: Firestoreに直接保存
        await FirebaseFirestore.instance.collection('studyRecords').add(record);
      }
    }
  }
}
