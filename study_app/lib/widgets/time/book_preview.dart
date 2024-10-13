import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/user/book_shelf.dart';

class BookSelectionPage extends StatefulWidget {
  final Map<int, Book> bookInfos;
  final Function(int) onBookSelected;

  const BookSelectionPage({
    Key? key,
    required this.bookInfos,
    required this.onBookSelected,
  }) : super(key: key);

  @override
  _BookSelectionPageState createState() => _BookSelectionPageState();
}

class _BookSelectionPageState extends State<BookSelectionPage> {
  String? selectedCategory; // ドロップダウンで選択されたカテゴリー

  @override
  Widget build(BuildContext context) {
    // 全ての本のカテゴリーリストを作成（重複削除）
    List<String> bookCategories =
        widget.bookInfos.values.map((book) => book.category).toSet().toList();
    bookCategories.insert(0, '全てのカテゴリー'); // 「全てのカテゴリー」を最初に追加して全て表示できるようにする

    // フィルタリング
    Map<int, Book> filteredBookInfos;

    if (selectedCategory == null || selectedCategory == '全てのカテゴリー') {
      // "全てのカテゴリー" が選ばれている場合は、isRecentlyUseがtrueのもののみ表示
      filteredBookInfos = Map.fromEntries(widget.bookInfos.entries
          .where((entry) => entry.value.isRecentlyUse == true));
    } else {
      // その他のカテゴリーが選ばれている場合は、選ばれたカテゴリーでフィルタリング
      filteredBookInfos = Map.fromEntries(widget.bookInfos.entries
          .where((entry) => entry.value.category == selectedCategory));
    }

    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(), // AppBarはそのまま
      floatingActionButton: Container(
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: primary,
          child: const Icon(
            color: Colors.white,
            Icons.add,
            size: 50,
          ),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle, // rectangleを使用
          color: Colors.green, // 背景色を指定
          borderRadius: BorderRadius.circular(50), // ここでradiusを設定
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10, // ぼかしの範囲
              offset: Offset(0, 4), // 影の位置
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ドロップダウンメニューをAppBarの下に配置
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 右上に配置
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
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
                    ),
                  )
                ],
              ),
            ),

            if (selectedCategory == null || selectedCategory == '全てのカテゴリー') ...[
              Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 13,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 13),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '最近使用した教材',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: "KiwiMaru-Regular"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // GridViewの表示
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 1,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredBookInfos.length,
                itemBuilder: (BuildContext context, int index) {
                  final bookKey = filteredBookInfos.keys.elementAt(index);
                  final book = filteredBookInfos[bookKey]!;
                  return GestureDetector(
                    onTap: () {
                      widget.onBookSelected(bookKey); // 本が選択された時にコールバックを呼ぶ
                    },
                    child: BookCard(
                      bookImgUrl: book.bookImgUrl,
                      name: book.name,
                      studyTime: 300,
                      isDisplayTime: false,
                    ),
                  );
                },
              ),
            ],
            Row(
              children: [
                SizedBox(
                  width: 13,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 13),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    selectedCategory.toString() == '全てのカテゴリー' ||
                            selectedCategory == null
                        ? '全ての教材'
                        : selectedCategory.toString(),
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: "KiwiMaru-Regular"),
                  ),
                ),
              ],
            ),
            // GridViewの表示
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 1,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredBookInfos.length,
              itemBuilder: (BuildContext context, int index) {
                final bookKey = filteredBookInfos.keys.elementAt(index);
                final book = filteredBookInfos[bookKey]!;
                return GestureDetector(
                  onTap: () {
                    widget.onBookSelected(bookKey); // 本が選択された時にコールバックを呼ぶ
                  },
                  child: BookCard(
                    bookImgUrl: book.bookImgUrl,
                    name: book.name,
                    studyTime: 300,
                    isDisplayTime: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
