class Book {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final DateTime lastUsedDate; // Add lastUsedDate field

  // コンストラクター
  Book({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.lastUsedDate, // Add lastUsedDate to constructor
  });

  // FirestoreのデータからBookオブジェクトを生成するファクトリメソッド
  factory Book.fromFirestore(Map<String, dynamic> data) {
    return Book(
      id: data['id'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      lastUsedDate: (data['lastUsedDate'] != null)
          ? DateTime.parse(data['lastUsedDate'])
          : DateTime.now(), // Add lastUsedDate to factory method
    );
  }

  // BookオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'category': category,
      'lastUsedDate':
          lastUsedDate.toIso8601String(), // Add lastUsedDate to toMap method
    };
  }

  // 最近使用したかどうかを判定する関数
  bool wasUsedRecently() {
    final now = DateTime.now();
    final difference = now.difference(lastUsedDate).inDays;
    return difference <= 30;
  }
}
