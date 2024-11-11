import 'package:study_app/models/book.dart'; // Bookモデルをインポート

class StudyMaterial {
  final Book book; // Bookオブジェクトを保持
  final int studyTime;

  StudyMaterial({
    required this.book,
    required this.studyTime,
  });

  // FirestoreのデータからStudyMaterialオブジェクトを生成するファクトリメソッド
  factory StudyMaterial.fromFirestore(Map<String, dynamic> data) {
    // FirestoreからのデータをBookオブジェクトに変換
    Book book = Book(
      id: data['id'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '', // Add category here
      lastUsedDate: data['lastUsedDate'] != null
          ? DateTime.parse(data['lastUsedDate'])
          : DateTime.now(),
    );

    return StudyMaterial(
      book: book,
      studyTime: data['studyTime'] ?? 0,
    );
  }

  // StudyMaterialオブジェクトをMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': book.id,
      'imgUrl': book.imgUrl,
      'title': book.title,
      'category': book.category, // Add category here
      'studyTime': studyTime,
    };
  }

  // 時間と分を表示形式に変換するメソッド
  String get formattedStudyTime {
    int hours = studyTime ~/ 60;
    int minutes = studyTime % 60;
    return '${hours}時間${minutes}分';
  }
}
