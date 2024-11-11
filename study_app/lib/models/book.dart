import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String imgUrl;
  final String title;
  final String category;
  final DateTime lastUsedDate; // lastUsedDateフィールドを追加

  // コンストラクター
  Book({
    required this.id,
    required this.imgUrl,
    required this.title,
    required this.category,
    required this.lastUsedDate, // コンストラクターにlastUsedDateを追加
  });

  // FirestoreのデータからBookオブジェクトを生成するファクトリメソッド
  factory Book.fromFirestore(Map<String, dynamic> data) {
    return Book(
      id: data['bookId'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      lastUsedDate: data['lastUsedDate'] is Timestamp
          ? (data['lastUsedDate'] as Timestamp).toDate()
          : DateTime.parse(
              data['lastUsedDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  // BookオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imgUrl': imgUrl,
      'title': title,
      'category': category,
      'lastUsedDate': lastUsedDate.toIso8601String(), // lastUsedDateをtoMapに追加
    };
  }

  // 最近使用したかどうかを判定する関数
  bool wasUsedRecently() {
    final now = DateTime.now();
    final difference = now.difference(lastUsedDate).inDays;
    return difference <= 30;
  }
}
