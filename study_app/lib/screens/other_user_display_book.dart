import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';
import 'package:study_app/widgets/user/book_shelf.dart';

class OtherUserBookShelf extends StatefulWidget {
  final Map<int, Book> bookInfos;

  const OtherUserBookShelf({
    Key? key,
    required this.bookInfos,
  }) : super(key: key);

  @override
  _OtherUserBookShelfState createState() => _OtherUserBookShelfState();
}

class _OtherUserBookShelfState extends State<OtherUserBookShelf> {
  String? selectedCategory; // ドロップダウンで選択されたカテゴリー

  void onBookSelected(int bookKey) {
    print(bookKey);
  }

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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ドロップダウンメニューをAppBarの下に配置
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 右上に配置
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // 選択中の背景色を白に設定
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: backGroundColor,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
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
                          dropdownColor: Colors.white, // ドロップダウンの背景色を白に設定
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                SizedBox(
                  width: 13,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 13),
                  decoration: BoxDecoration(
                    color: subTheme,
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
                final bookKey = widget.bookInfos.keys.elementAt(index);
                final book = widget.bookInfos[bookKey]!;
                return GestureDetector(
                  onTap: () {
                    onBookSelected(bookKey); // 本が選択された時にコールバックを呼ぶ
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
