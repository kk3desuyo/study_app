import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/user/user_service.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> userHasBook(String bookId) async {
    UserService userService = UserService();
    String userId = userService.getCurrentUserId()!;

    final firestore = FirebaseFirestore.instance;

    try {
      // ユーザーの `books` コレクションから指定された `bookId` を検索
      CollectionReference booksCollection =
          firestore.collection('users').doc(userId).collection('books');

      QuerySnapshot bookQuery = await booksCollection
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      // 該当するドキュメントがあれば、trueを返す
      return bookQuery.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if user has book: $e");
      return false;
    }
  }

  Future<void> addPrivateBookToUser(
      String userId, String category, String imgUrl, String title) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print("Attempting to add private book for the user...");
      print(
          "User ID: $userId, Category: $category, ImgUrl: $imgUrl, Title: $title");

      // `privateBooks`コレクションをユーザーのドキュメント直下に作成
      CollectionReference privateBooksCollection =
          firestore.collection('users').doc(userId).collection('privateBooks');

      await privateBooksCollection.add({
        'lastUsedDate': Timestamp.fromDate(DateTime.now()),
        'category': category,
        'imgUrl': imgUrl,
        'title': title,
      });

      print("Private book added successfully.");
    } catch (e) {
      print("Error adding private book: $e");
      throw Exception('Failed to add private book');
    }
  }

  Future<List<Book>> getBooksByIds(List<String> bookIds) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Book(
          id: doc.id,
          imgUrl: data['imgUrl'] ?? '',
          title: data['title'] ?? '',
          category: data['categoryId'] ?? '',
          lastUsedDate: data['lastUsedDate'] != null
              ? (data['lastUsedDate'] as Timestamp).toDate()
              : DateTime.now(),
          userNum: data['userNum'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting books by ids: $e');
      throw Exception('Failed to get books');
    }
  }

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

  Future<void> addNewCategory(String categoryName) async {
    try {
      UserService userService = UserService();
      String userId = userService.getCurrentUserId()!;
      CollectionReference categoriesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Check if the category already exists
      QuerySnapshot categoryQuery = await categoriesCollection
          .where('category', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (categoryQuery.docs.isEmpty) {
        // If the category does not exist, add it
        await categoriesCollection.add({
          'category': categoryName,
        });
        print("Category added successfully.");
      } else {
        // If the category already exists, do nothing
        print("Category already exists. No action taken.");
      }
    } catch (e) {
      print("Error adding new category: $e");
    }
  }

  Future<void> updatePrivateBook({
    required String userId, // ユーザーID
    required String privateBookId, // privateBooks ドキュメントID
    String? newCategoryId, // 更新する新しいカテゴリーID
    String? newTitle, // 更新する新しいタイトル
    String? newImageUrl, // 更新する新しい画像URL
  }) async {
    try {
      // Firestore のドキュメント参照を取得
      DocumentReference privateBookRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('privateBooks')
          .doc(privateBookId);

      // 更新するデータをマップで作成
      Map<String, dynamic> updatedData = {};
      if (newCategoryId != null) updatedData['category'] = newCategoryId;
      if (newTitle != null) updatedData['title'] = newTitle;
      if (newImageUrl != null) updatedData['imgUrl'] = newImageUrl;

      // Firestore ドキュメントを更新
      await privateBookRef.update(updatedData);

      print('Private book updated successfully!');
    } catch (e) {
      print('Error updating private book: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBookDetails(
      String userId, bool isFetchPrivateBook) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Step 1: ユーザーの `books` コレクションから全ての本を取得
      CollectionReference userBooksCollection =
          firestore.collection('users').doc(userId).collection('books');

      QuerySnapshot userBooksSnapshot = await userBooksCollection.get();

      // プライベートブック用の準備
      QuerySnapshot? userPrivateBooksSnapshot; // 初期値を null に設定
      if (isFetchPrivateBook) {
        userPrivateBooksSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('privateBooks')
            .get();
      }

      // ユーザーの本の情報をリストに格納
      List<Map<String, dynamic>> userBooks = userBooksSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'bookId': doc['bookId'] as String,
          'lastUsedDate': (doc['lastUsedDate'] as Timestamp).toDate(),
          'categoryId': doc['categoryId'] as String,
          'isPrivate': false,
        };
      }).toList();

      // Step 2: `bookIds` を使って `books` コレクションから本の詳細を取得
      List<String> bookIds =
          userBooks.map((book) => book['bookId'] as String).toList();

      QuerySnapshot booksSnapshot = await firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      // 本の詳細情報をマップに格納
      Map<String, Map<String, dynamic>> bookDetailsMap = {
        for (var doc in booksSnapshot.docs)
          doc.id: {
            'bookId': doc.id,
            'title': doc['title'],
            'imgUrl': doc['imgUrl'],
            'userNum': doc['userNum'],
          }
      };

      // `categoryId` のリストを取得
      List<String> categoryIds = userBooks
          .map((book) => book['categoryId'] as String)
          .toSet()
          .toList();

      // Step 3: `categories` コレクションからカテゴリ名を取得
      QuerySnapshot categoriesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .where(FieldPath.documentId, whereIn: categoryIds)
          .get();

      Map<String, String> categoryMap = {
        for (var doc in categoriesSnapshot.docs)
          doc.id: doc['category'] as String,
      };

      // `bookDetails` を作成
      List<Map<String, dynamic>> bookDetails = userBooks.map((userBook) {
        var bookDetail = bookDetailsMap[userBook['bookId']] ?? {};
        return {
          ...bookDetail,
          'category':
              categoryMap[userBook['categoryId']] ?? 'Unknown', // カテゴリ名を追加
          'lastUsedDate': userBook['lastUsedDate'],
        };
      }).toList();

      // プライベート本を取得しない場合にはここでリターン
      if (!isFetchPrivateBook) {
        return bookDetails;
      }

      // Step 4: プライベートブックを追加
      List<Map<String, dynamic>> privateBooks =
          (userPrivateBooksSnapshot?.docs ?? [])
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'bookId': doc.id,
                  'category': data['category'] ?? 'Unknown',
                  'imgUrl': data['imgUrl'] ?? '',
                  'userNum': 0,
                  'lastUsedDate': (data['lastUsedDate'] as Timestamp).toDate(),
                  'title': data['title'] ?? 'No Title',
                  'isPrivate': true,
                };
              })
              .where((book) => book['title'] != null) // 不要なデータを除外
              .toList();

      // プライベートブックを結合して返す
      return [...bookDetails, ...privateBooks];
    } catch (e) {
      print("Error fetching user book details: $e");
      return [];
    }
  }

  // userNumをインクリメントする関数
  Future<void> incrementUserNum(String bookId) async {
    print('Incrementing userNum for book: $bookId');
    DocumentReference bookRef = _firestore.collection('books').doc(bookId);
    try {
      await bookRef.update({
        'userNum': FieldValue.increment(1), // インクリメント
      });
      print('userNum incremented successfully.');
    } catch (e) {
      print('Failed to increment userNum: $e');
      throw Exception('Failed to increment userNum');
    }
  }

  // ユーザーの全てのカテゴリーを取得する関数
  Future<List<Map<String, dynamic>>> getUserCategories(String userId) async {
    try {
      // ユーザーの `categories` コレクションを参照
      CollectionReference categoriesCollection =
          _firestore.collection('users').doc(userId).collection('categories');

      // `categories` コレクションの全てのドキュメントを取得
      QuerySnapshot snapshot = await categoriesCollection.get();

      // 取得したドキュメントをリスト形式で返す
      return snapshot.docs.map((doc) {
        return {
          'categoryId': doc.id,
          'category': doc['category'],
          // 必要に応じて他のフィールドもここに追加可能
        };
      }).toList();
    } catch (e) {
      print("Error fetching user categories: $e");
      return [];
    }
  }

  // userNumをデクリメントする関数
  Future<void> decrementUserNum(String bookId) async {
    DocumentReference bookRef = _firestore.collection('books').doc(bookId);

    try {
      await bookRef.update({
        'userNum': FieldValue.increment(-1), // デクリメント
      });
      print('userNum decremented successfully.');
    } catch (e) {
      print('Failed to decrement userNum: $e');
      throw Exception('Failed to decrement userNum');
    }
  }

  Future<void> addBookToUser(String userId, String bookId,
      DateTime lastUsedDate, String category) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print(
          "Attempting to add book ID and last used date to user's collection...");
      print(
          "User ID: $userId, Book ID: $bookId, Last Used Date: $lastUsedDate, Category Name: $category");

      // ユーザーの `categories` コレクションから、category に一致するカテゴリを取得
      CollectionReference categoriesCollection =
          firestore.collection('users').doc(userId).collection('categories');

      QuerySnapshot categoryQuery = await categoriesCollection
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      String categoryId;

      if (categoryQuery.docs.isEmpty) {
        // カテゴリが存在しない場合、新しく作成
        DocumentReference newCategoryRef = categoriesCollection.doc();
        categoryId = newCategoryRef.id;

        await newCategoryRef.set({
          'category': category,
        });

        print("New category created with ID: $categoryId");
      } else {
        // 既存のカテゴリを使用
        DocumentSnapshot categoryDoc = categoryQuery.docs.first;
        categoryId = categoryDoc.id;

        print("Existing category found with ID: $categoryId");
      }

      // ユーザーの `books` コレクションから、bookId に一致する本を検索
      CollectionReference booksCollection =
          firestore.collection('users').doc(userId).collection('books');

      QuerySnapshot bookQuery = await booksCollection
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (bookQuery.docs.isEmpty) {
        // 本が存在しない場合、新しく追加
        DocumentReference newBookRef = booksCollection.doc();

        await newBookRef.set({
          'bookId': bookId,
          'lastUsedDate': Timestamp.fromDate(lastUsedDate),
          'categoryId': categoryId,
        });
        incrementUserNum(bookId);

        print("Book added successfully to user's collection.");
      } else {
        // 本が既に存在する場合、追加しない
        print("Book already exists in user's collection. No action taken.");
      }
    } catch (e) {
      print("Error adding book ID and last used date to user's collection: $e");
      throw Exception('Failed to add book ID and last used date to user');
    }
  }
}
