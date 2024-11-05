class Event {
  final String id;
  final String name;

  Event({required this.id, required this.name});

  // FirestoreのドキュメントをEventオブジェクトに変換
  factory Event.fromDocument(Map<String, dynamic> doc, String docId) {
    return Event(
      id: docId,
      name: doc['name'] ?? '',
    );
  }

  // EventオブジェクトをMapに変換（Firestoreへの保存用）
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
