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
      // Step 1: `users`コレクションのサブコレクション`books`から指定した`userId`の本を取得
      QuerySnapshot userBooksSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .get();

      // `bookId`と `lastUsedDate` をリストに変換
      List<Map<String, dynamic>> userBooks = userBooksSnapshot.docs.map((doc) {
        return {
          'bookId': doc['bookId'] as String,
          'lastUsedDate': (doc['lastUsedDate'] as Timestamp)
              .toDate() // TimestampをDateTimeに変換
        };
      }).toList();

      if (userBooks.isEmpty) {
        return []; // 教材が見つからない場合、空のリストを返す
      }

      // `bookId`のリストを取得
      List<String> bookIds =
          userBooks.map((book) => book['bookId'] as String).toList();

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

      // bookDetailsにカテゴリ名とlastUsedDateを追加
      bookDetails = bookDetails.map((book) {
        // userBooksから該当のbookIdのlastUsedDateを取得
        final lastUsedDate = userBooks.firstWhere(
            (userBook) => userBook['bookId'] == book['bookId'])['lastUsedDate'];
        for (var entry in {
          ...book,
          'categoryName':
              categoryMap[book['categoryId']] ?? 'Unknown', // カテゴリ名を追加
          'lastUsedDate': lastUsedDate, // lastUsedDateを追加
        }.entries) {
          print('${entry.key}: ${entry.value}');
        }
        return {
          ...book,
          'categoryName':
              categoryMap[book['categoryId']] ?? 'Unknown', // カテゴリ名を追加
          'lastUsedDate': lastUsedDate, // lastUsedDateを追加
        };
      }).toList();

      return bookDetails;
    } catch (e) {
      print("Error fetching user book details: $e");
      return [];
    }
  }

  Future<void> addBookToUser(
      String userId, String bookId, DateTime lastUsedDate) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print(
          "Attempting to add book ID and last used date to user's collection...");
      print(
          "User ID: $userId, Book ID: $bookId, Last Used Date: $lastUsedDate");

      // `lastUsedDate` を Firestore に保存できるように `Timestamp` に変換
      await firestore.collection('users').doc(userId).collection('books').add({
        'bookId': bookId,
        'lastUsedDate': Timestamp.fromDate(lastUsedDate), // 日付を Firestore に保存
      });

      print(
          "Book ID and last used date added successfully to user's collection.");
    } catch (e) {
      print("Error adding book ID and last used date to user's collection: $e");
      throw Exception('Failed to add book ID and last used date to user');
    }
  }
}
