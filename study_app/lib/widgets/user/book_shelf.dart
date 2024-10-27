import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/models/book.dart'; // Import the Book model

class BookShelfCard extends StatefulWidget {
  final List<Book> books; // List<Book>に変更

  BookShelfCard({
    required this.books, // Required list of books
    Key? key,
  }) : super(key: key);

  @override
  _BookShelfCardState createState() => _BookShelfCardState();
}

class _BookShelfCardState extends State<BookShelfCard> {
  late Set<String> categorySet;
  String isSelectedCategory = '全てのカテゴリー'; // 初期選択値

  @override
  void initState() {
    super.initState();

    // booksからcategorySetを生成
    categorySet = widget.books.map((book) => book.category).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 27),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '教材一覧',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 5, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<String>(
                  style: TextStyle(color: Colors.black),
                  value: isSelectedCategory,
                  items: _buildDropdownItems(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        isSelectedCategory = value;
                      });
                    }
                  },
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _filteredBooks().length,
            itemBuilder: (context, index) {
              return Container(
                child: Center(
                  child: _buildBookCard(_filteredBooks()[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 選択されたカテゴリに基づいて本をフィルタリング
  List<Book> _filteredBooks() {
    if (isSelectedCategory == '全てのカテゴリー') {
      return widget.books;
    } else {
      return widget.books
          .where((book) => book.category == isSelectedCategory)
          .toList();
    }
  }

  // ドロップダウンのアイテムを生成
  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final categories =
        widget.books.map((book) => book.category).toSet().toList();
    categories.insert(0, '全てのカテゴリー');

    return categories
        .map((category) => DropdownMenuItem<String>(
              value: category as String,
              child: Text(category),
            ))
        .toList();
  }

  // 最近使用した教材かどうかを調べる関数
  bool isRecentlyUsed(Book book) {
    // ここに最近使用したかどうかを判定するロジックを追加
    // 例えば、book.lastUsedDateが一定期間内であればtrueを返す
    return book.lastUsedDate
        .isAfter(DateTime.now().subtract(Duration(days: 30)));
  }

  Widget _buildBookCard(Book book) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Column(
        children: [
          Expanded(
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/book_placeholder.png',
              image: book.imageUrl,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/book_placeholder.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              book.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isRecentlyUsed(book) ? 'Recently Used' : '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
