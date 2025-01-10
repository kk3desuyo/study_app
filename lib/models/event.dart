import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String name;
  final DateTime date;

  Event({
    required this.name,
    required this.date,
  });

  // FirestoreのドキュメントをEventオブジェクトに変換
  factory Event.fromDocument(Map<String, dynamic> doc, String docId) {
    return Event(
      name: doc['name'] ?? '',
      date: (doc['date'] as Timestamp).toDate(),
    );
  }

  // EventオブジェクトをMapに変換（Firestoreへの保存用）
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
    };
  }
}
