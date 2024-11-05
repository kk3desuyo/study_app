import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  Future<String?> fetchBookName(String bookId) async {
    try {
      // booksコレクションからbookNameを取得
      DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      if (bookSnapshot.exists) {
        return bookSnapshot['title']; // bookNameとしてタイトルを取得
      } else {
        return 'Book not found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBookDetails(String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Step 1: `userBooks`コレクションから、指定した`userId`を持つ`bookId`を取得
      QuerySnapshot userBooksSnapshot = await firestore
          .collection('userBooks')
          .where('userId', isEqualTo: userId)
          .get();

      // `bookId`をリストに変換
      List<String> bookIds =
          userBooksSnapshot.docs.map((doc) => doc['bookId'] as String).toList();

      if (bookIds.isEmpty) {
        return []; // 教材が見つからない場合、空のリストを返す
      }

      // Step 2: `bookIds`リストを使って`books`コレクションに対して`in`クエリを実行
      QuerySnapshot booksSnapshot = await firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      // 各教材のデータとcategoryIdのリストを取得
      List<Map<String, dynamic>> bookDetails = booksSnapshot.docs.map((doc) {
        return {
          'bookId': doc.id,
          'title': doc['title'],
          'imgUrl': doc['imgUrl'],
          'categoryId': doc['categoryId'],
        };
      }).toList();

      // ユニークなcategoryIdを取得
      List<String> categoryIds = bookDetails
          .map((book) => book['categoryId'] as String)
          .toSet()
          .toList();

      // Step 3: `categoryIds`リストを使って`categories`コレクションに対して`in`クエリを実行
      QuerySnapshot categoriesSnapshot = await firestore
          .collection('categories')
          .where(FieldPath.documentId, whereIn: categoryIds)
          .get();

      // categoryIdとカテゴリ名のマップを作成
      Map<String, String> categoryMap = {
        for (var doc in categoriesSnapshot.docs) doc.id: doc['name'] as String
      };

      // bookDetailsにカテゴリ名を追加
      bookDetails = bookDetails.map((book) {
        return {
          ...book,
          'categoryName':
              categoryMap[book['categoryId']] ?? 'Unknown', // カテゴリ名を追加
        };
      }).toList();

      return bookDetails;
    } catch (e) {
      print("Error fetching user book details: $e");
      return [];
    }
  }
}
