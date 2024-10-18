import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class Book {
  final String bookImgUrl;
  final String category;
  final String name;
  final int id;
  final bool isRecentlyUse;

  Book(
      {required this.bookImgUrl,
      required this.category,
      required this.id,
      required this.name,
      required this.isRecentlyUse});
}

class BookShelfCard extends StatefulWidget {
  final List<Book> books;
  final Set<String> categorySet; // Setを定義

  BookShelfCard({
    required this.books,
    this.categorySet = const <String>{}, // デフォルトで空のSetを持つ
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
                  color: Colors.white, // 背景色を白に設定
                  borderRadius: BorderRadius.circular(5), // 角を少し丸くする（オプション）
                  border: Border.all(color: Colors.grey), // 境界線を設定（オプション）
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<String>(
                  style: TextStyle(color: Colors.black), // テキストのスタイルを調整
                  value: isSelectedCategory, // 選択された値
                  items: _buildDropdownItems(), // ドロップダウンのアイテム
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        isSelectedCategory = value; // ドロップダウンの選択に基づいて状態を更新
                      });
                    }
                  },
                  dropdownColor: Colors.white, // ドロップダウンメニューの背景色を白に設定
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 例: 3列にする場合
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _filteredBooks().length, // フィルタリングしたアイテム数
            itemBuilder: (context, index) {
              return Container(
                child: Center(
                  child:
                      _buildBookCard(_filteredBooks()[index]), // フィルタリングされた本を表示
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
    // 重複しないカテゴリーリストを生成
    final categories =
        widget.books.map((book) => book.category).toSet().toList();

    // デフォルトの「全てのカテゴリー」をリストの先頭に追加
    categories.insert(0, '全てのカテゴリー');

    return categories
        .map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ))
        .toList();
  }

  Widget _buildBookCard(Book book) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // カードの角を丸くする
      ),
      elevation: 5, // 影をつける
      child: Column(
        children: [
          Expanded(
            child: FadeInImage.assetNetwork(
              placeholder:
                  'assets/images/book_placeholder.png', // プレースホルダーとしてのローカル画像（本アイコン）
              image: book.bookImgUrl,
              fit: BoxFit.cover, // 画像をカード内に収める
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/book_placeholder.png', // エラー時に表示する画像
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              book.category,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
