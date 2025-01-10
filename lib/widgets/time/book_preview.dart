import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/screens/serch_book.dart';

import 'package:study_app/services/book_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/time/book_edit_modal.dart';

class BookSelectionPage extends StatefulWidget {
  final Function(Book) onEditBook;
  const BookSelectionPage({
    Key? key,
    required this.onEditBook,
  }) : super(key: key);

  @override
  _BookSelectionPageState createState() => _BookSelectionPageState();
}

class _BookSelectionPageState extends State<BookSelectionPage> {
  String? selectedCategory; // 現在選択されているカテゴリー
  bool isEdit = false;
  bool isLoading = false;
  Map<int, Book> bookInfos = {};
  List<Book> recentBooks = []; // 最近使用した教材を保持するリスト

  @override
  void initState() {
    super.initState();
    fetchBookInfos();
  }

  Future<void> fetchBookInfos() async {
    setState(() {
      isLoading = true;
    });

    try {
      BookService bookService = BookService();
      String? userId = await UserService().getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID is null or empty');
      }

      List<Map<String, dynamic>> fetchedBooks =
          await bookService.fetchUserBookDetails(userId, true);
      print("sss");
      List<Book> books = fetchedBooks.map((data) {
        return Book.fromFirestore({
          ...data,
          'lastUsedDate': data['lastUsedDate'].toIso8601String(),
        });
      }).toList();
      print("aaa");
      // lastUsedDateでソートして最近使用した教材を取得
      books.sort((a, b) => b.lastUsedDate.compareTo(a.lastUsedDate));
      recentBooks = books.take(6).toList();

      setState(() {
        bookInfos = {
          for (var i = 0; i < books.length; i++) i: books[i],
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching book infos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onBookAdd() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: SearchBook(), // 遷移先の画面
      withNavBar: false, // ナビゲーションバーを非表示にする
      pageTransitionAnimation: PageTransitionAnimation.cupertino, // アニメーションの種類
    );
  }

  Future<void> showDeleteBookDialogIfNeeded(
      BuildContext context, String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final hideUntil = prefs.getInt('hideDeleteDialogUntil') ?? 0;

    // 現在時刻がタイムスタンプを過ぎている場合のみダイアログを表示
    if (DateTime.now().millisecondsSinceEpoch > hideUntil) {
      await _showConfirmDeleteBook(context, bookId);
    } else {
      try {
        await deleteBook(bookId, true);
      } catch (e) {}
      print('ダイアログをスキップしました: 今後1時間は表示しないが有効です');
    }
  }

  Future<void> deleteBook(String bookId, bool isPrivateBook) async {
    try {
      String? userId = UserService().getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID is null or empty');
      }
      if (isPrivateBook)
        await BookService().deletePrivateBook(userId, bookId);
      else
        await BookService().deletePublicBook(userId, bookId);

      // ローカルの状態から本を削除
      setState(() {
        bookInfos.removeWhere((key, book) => book.id == bookId);
        recentBooks.removeWhere((book) => book.id == bookId);
      });
    } catch (e) {
      // 削除中に発生したエラーを処理
      print('Error deleting book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('教材の削除に失敗しました。もう一度お試しください。'),
        ),
      );
    }
  }

  Future<dynamic> _showConfirmDeleteBook(
      BuildContext context, String bookId) async {
    bool doNotShowAgain = false; // チェックボックスの初期値

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // チェックボックスの状態を管理するためにStatefulBuilderを使用
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 30),
                    const SizedBox(height: 20),
                    const Text(
                      '教材を消去しますか?',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      onPressed: () async {
                        // 「今後1時間は表示しない」を選択した場合、タイムスタンプを保存
                        if (doNotShowAgain) {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setInt(
                              'hideDeleteDialogUntil',
                              DateTime.now()
                                  .add(const Duration(hours: 1))
                                  .millisecondsSinceEpoch);
                        }
                        try {
                          await deleteBook(bookId, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('教材を削除しました。'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('教材の削除に失敗しました。もう一度お試しください。'),
                            ),
                          );
                        }
                        Navigator.of(context).pop(); // ダイアログを閉じる
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    Checkbox(
                      value: doNotShowAgain,
                      onChanged: (bool? value) {
                        setState(() {
                          doNotShowAgain = value ?? false;
                        });
                      },
                    ),
                    const Flexible(
                      child: Text(
                        '今後1時間は表示しない',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  /// 編集後の教材を処理するメソッド
  void onEdited(Book book) {
    widget.onEditBook(book); // 親ウィジェットに通知
    setState(() {
      // bookInfosを更新
      int key = bookInfos.keys
          .firstWhere((key) => bookInfos[key]!.id == book.id, orElse: () => -1);
      if (key != -1) {
        bookInfos[key] = book;
      }

      // recentBooksを再計算
      recentBooks = bookInfos.values.toList()
        ..sort((a, b) => b.lastUsedDate.compareTo(a.lastUsedDate));
      recentBooks = recentBooks.take(6).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // カテゴリーリストの作成
    List<String> bookCategories = bookInfos.values
        .map((book) => book.category.isNotEmpty ? book.category : 'カテゴリーなし')
        .toSet()
        .toList();

    // "全てのカテゴリー"を先頭に追加
    bookCategories.insert(0, '全てのカテゴリー');

    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 教材を編集するボタン
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isEdit = !isEdit;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isEdit ? Colors.red : subTheme,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isEdit)
                              Icon(
                                Icons.collections_bookmark,
                                color: isEdit ? Colors.red : subTheme,
                                size: 20,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              isEdit ? 'キャンセル' : '教材を編集する',
                              style: TextStyle(
                                fontSize: 18,
                                color: isEdit ? Colors.red : subTheme,
                                fontWeight: FontWeight.w900,
                                fontFamily: "KiwiMaru-Regular",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isEdit)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 5),
                      child: GestureDetector(
                        onTap: onBookAdd,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 13),
                          decoration: BoxDecoration(
                            color: subTheme,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: subTheme,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '教材を追加する',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "KiwiMaru-Regular",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // カテゴリードロップダウン
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: backGroundColor,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                hint: const Text('全てのカテゴリー'),
                                items: bookCategories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue;
                                  });
                                },
                                dropdownColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  buildContent(),
                ],
              ),
            ),
    );
  }

  Widget buildContent() {
    if (selectedCategory == null || selectedCategory == '全てのカテゴリー') {
      // 全てのカテゴリーが選択された場合
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最近使用した教材を表示
          if (recentBooks.isNotEmpty) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 13),
                decoration: BoxDecoration(
                  color: subTheme,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '最近使用した教材',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: "KiwiMaru-Regular",
                  ),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: recentBooks.length,
              itemBuilder: (BuildContext context, int index) {
                final book = recentBooks[index];
                return GestureDetector(
                  onTap: () {
                    print(book.imgUrl);
                    if (isEdit) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return CustomBookEntryModal(
                            book: book,
                            onChanged: onEdited, // 編集後のコールバックを渡す
                          );
                        },
                      );
                    } else
                      Navigator.pop(context, book); // 選択した本を返す
                  },
                  child: Stack(
                    children: [
                      // BookCard ウィジェット
                      BookCard(
                        book: book,
                        studyTime: 300,
                        isDisplayTime: false,
                        isTapDisabled: true,
                      ),
                      // 編集モードの場合、削除ボタンを表示
                      if (isEdit)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              print("削除ボタンがタップされました");
                              print(book.id);
                              await showDeleteBookDialogIfNeeded(
                                  context, book.id);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
          // カテゴリーごとに表示
          ...buildBooksByCategory(),
        ],
      );
    } else {
      // 特定のカテゴリーが選択された場合
      List<Book> filteredBooks = bookInfos.values
          .where((book) =>
              (book.category.isNotEmpty ? book.category : 'カテゴリーなし') ==
              selectedCategory)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 選択したカテゴリー名を表示
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 13),
              decoration: BoxDecoration(
                color: subTheme,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                selectedCategory ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: "KiwiMaru-Regular",
                ),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (BuildContext context, int index) {
              final book = filteredBooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, book); // 選択した本を返す
                },
                child: Stack(
                  children: [
                    // BookCard ウィジェット
                    BookCard(
                      book: book,
                      studyTime: 300,
                      isDisplayTime: false,
                      isTapDisabled: true,
                    ),
                    // 編集モードの場合、削除ボタンを表示
                    if (isEdit)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            print("削除ボタンがタップされました");
                            print(book.id);
                            await showDeleteBookDialogIfNeeded(
                                context, book.id);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }

  List<Widget> buildBooksByCategory() {
    Map<String, List<Book>> booksByCategory = {};
    for (var book in bookInfos.values) {
      String category = book.category.isNotEmpty ? book.category : 'カテゴリーなし';
      if (!booksByCategory.containsKey(category)) {
        booksByCategory[category] = [];
      }
      booksByCategory[category]!.add(book);
    }

    return booksByCategory.entries.map((entry) {
      String category = entry.key;
      List<Book> books = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリー名を表示
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 13),
              decoration: BoxDecoration(
                color: subTheme,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: "KiwiMaru-Regular",
                ),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: books.length,
            itemBuilder: (BuildContext context, int index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, book); // 選択した本を返す
                },
                child: Stack(
                  children: [
                    // BookCard ウィジェット
                    BookCard(
                      book: book,
                      studyTime: 300,
                      isDisplayTime: false,
                      isTapDisabled: true,
                    ),
                    // 編集モードの場合、削除ボタンを表示
                    if (isEdit)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            print("削除ボタンがタップされました");
                            print(book.id);
                            await showDeleteBookDialogIfNeeded(
                                context, book.id);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }).toList();
  }
}
