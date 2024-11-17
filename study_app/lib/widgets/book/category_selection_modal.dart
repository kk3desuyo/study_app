import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/theme/color.dart';

class CategorySelectionModal extends StatefulWidget {
  final String userId;
  final String bookId;

  const CategorySelectionModal(
      {Key? key, required this.userId, required this.bookId})
      : super(key: key);

  @override
  _CategorySelectionModalState createState() => _CategorySelectionModalState();
}

class _CategorySelectionModalState extends State<CategorySelectionModal>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryId;
  bool isLoading = true;
  final TextEditingController _categoryController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> fetchCategories() async {
    try {
      CollectionReference categoriesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('categories');

      QuerySnapshot snapshot = await categoriesCollection.get();

      setState(() {
        categories = snapshot.docs.map((doc) {
          return {
            'categoryId': doc.id,
            'category': doc['category'] as String,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("category_selection");
      print("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4), // 横の余白を減らす
      backgroundColor: Colors.white,
      title: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 27),
          decoration: BoxDecoration(
            color: subTheme,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'カテゴリーを選択',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: double.maxFinite, // 幅を最大限に広げる
              height: 200,
              child: Column(
                children: [
                  // タブバーを追加
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: subTheme,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: CustomTabIndicator(),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(
                          child: Text(
                            '既存のカテゴリー',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'カテゴリーを追加',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // 既存のカテゴリーを選択
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedCategoryId,
                                hint: Text('カテゴリーを選択'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategoryId = newValue;
                                  });
                                },
                                items: categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category['categoryId'],
                                    child: Text(category['category'] ?? ''),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        // カテゴリーを新規追加
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  labelText: '新しいカテゴリー名',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: subTheme),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('キャンセル'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // ボタンの背景色を白に設定
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(color: subTheme),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          onPressed: () async {
            BookService bookService = BookService();
            String categoryName = '';
            //カテゴリー新規追加時のみ　カテゴリーをデータベースに追加
            if (_tabController.index == 1) {
              print(_categoryController.text);
              await bookService.addNewCategory(_categoryController.text);
              categoryName = _categoryController.text;
            }

            //既存のカテゴリー使用時
            if (selectedCategoryId != null && _tabController.index == 0) {
              categoryName = categories.firstWhere((category) =>
                  category['categoryId'] == selectedCategoryId)['category'];
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('カテゴリーが選択されていません'),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (categoryName.isNotEmpty) {
              await bookService.addBookToUser(
                  widget.userId, widget.bookId, DateTime.now(), categoryName);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('エラーが発生しました。'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(
            '決定',
            style: TextStyle(color: subTheme),
          ),
        ),
      ],
    );
  }
}

// CustomTabIndicatorクラスを追加
class CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter();
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const indicatorHeight = 2.0;
    const indicatorWidth = 20.0;

    final centerX = (configuration.size!.width / 2) + offset.dx;
    final startY = configuration.size!.height - indicatorHeight;

    final rect = Rect.fromCenter(
      center: Offset(centerX, startY),
      width: indicatorWidth,
      height: indicatorHeight,
    );

    canvas.drawRect(rect, paint);
  }
}
