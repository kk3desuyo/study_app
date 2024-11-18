import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/book/category_selection_modal.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';

class BookScreen extends StatefulWidget {
  final Book book;

  BookScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool? isHasBook; // nullableにして初期値をnullに設定

  void checkIfUserHasBook() async {
    BookService bookService = BookService();
    bool hasBook = await bookService.userHasBook(widget.book.id);
    setState(() {
      isHasBook = hasBook;
    });
  }

  // showCategorySelectionModal メソッドを修正
  Future<String?> showCategorySelectionModal(
      BuildContext context, String userId) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CategorySelectionModal(
          userId: userId,
          bookId: widget.book.id,
        );
      },
    );
  }

  // 教材を追加する際のモーダルを開く
  Future<void> _openCategorySelectionModal() async {
    UserService userService = UserService();
    String userId = userService.getCurrentUserId()!;

    // カテゴリ選択モーダルを表示
    String? selectedCategoryId =
        await showCategorySelectionModal(context, userId);

    // 選択されたカテゴリーIDがあれば教材を追加
    if (selectedCategoryId != null) {
      _addBookToUser(selectedCategoryId);
    }
  }

  void _addBookToUser(String categoryId) async {
    if (isHasBook == true) return;
    BookService bookService = BookService();
    UserService userService = UserService();
    String userId = userService.getCurrentUserId()!;

    await bookService.addBookToUser(
      userId,
      widget.book.id,
      DateTime.now(),
      categoryId,
    );

    setState(() {
      isHasBook = true;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfUserHasBook();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text('Book Screen'),
      ),
      body: isHasBook == null
          ? Center(child: CircularProgressIndicator()) // ローディング表示
          : Card(
              color: Colors.white,
              margin: EdgeInsets.all(10), // Card全体の外側マージン
              child: Padding(
                padding: EdgeInsets.all(10), // Card内側のパディング
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: widget.book.imgUrl.isNotEmpty
                                  ? Image.network(
                                      widget.book.imgUrl,
                                      width: 120,
                                      height: 140,
                                      fit: BoxFit.contain, // ここを変更
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/default_book_img.jpg',
                                          width: 120,
                                          height: 140,
                                          fit: BoxFit.contain, // ここも同様に変更
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/default_book_img.jpg',
                                      width: 120,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: 160,
                              child: Text(
                                widget.book.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 40),
                            Container(
                              height: 35,
                              width: 160,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: isHasBook! ? Colors.white : subTheme,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: subTheme),
                              ),
                              child: InkWell(
                                onTap: () => {
                                  if (isHasBook != null && !isHasBook!)
                                    {_openCategorySelectionModal()}
                                },
                                child: Center(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: isHasBook!
                                            ? subTheme
                                            : Colors.white,
                                        size: 25,
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        isHasBook! ? "登録済み" : "教材を追加",
                                        style: TextStyle(
                                          color: isHasBook!
                                              ? subTheme
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("ユーザー数"),
                            Text(
                              widget.book.userNum.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
