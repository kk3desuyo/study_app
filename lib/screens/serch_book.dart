import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/screens/barcode_scan.dart';
import 'package:study_app/screens/private_book_add.dart';
import 'package:study_app/theme/color.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';

class SearchBook extends StatefulWidget {
  @override
  _SearchBookState createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _submission(String text) {
    print(text);
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      // アクセス許可が既に与えられている場合、バーコード画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(),
          fullscreenDialog: true,
        ),
      );
    } else if (status.isDenied) {
      // アクセス許可が拒否された場合、再度リクエスト
      status = await Permission.camera.request();
      if (status.isGranted) {
        // 許可が与えられた場合、バーコード画面に遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeScannerScreen(),
            fullscreenDialog: true,
          ),
        );
      } else {
        // 再度拒否された場合、メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('カメラのアクセス許可が必要です。')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // アクセス許可が永久に拒否された場合、設定画面への誘導
      _showPermissionDialog();
    } else {
      // その他の状態（制限されているなど）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('カメラのアクセス許可が必要です。')),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('カメラのアクセス許可が必要です'),
        content: Text('カメラのアクセス許可が永久に拒否されています。設定画面から許可を与えてください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text('教材を追加',
            style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '教材を検索',
                    prefixIcon: Icon(Icons.search, color: subTheme),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: subTheme),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  onSubmitted: (text) => _submission(text),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _requestCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subTheme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 30) / 2,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'バーコードから検索',
                          style: GoogleFonts.notoSansJp(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        SimpleBarcode(),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomBookEntryScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 30) / 2,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '教材を作成',
                          style: GoogleFonts.notoSansJp(
                            fontWeight: FontWeight.w900, // 極太フォント
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'あなたにおすすめの本',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
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
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '同じタグの人が使っている本',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                              BookCard(
                                isDisplayTime: false,
                                book: Book(
                                  id: "1",
                                  category: 'Programming',
                                  lastUsedDate: DateTime.now(),
                                  isPrivate: false,
                                  categoryId: "101",
                                  title: 'Dart',
                                  imgUrl:
                                      'https://example.com/dart_programming.jpg',
                                ),
                                studyTime: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SimpleBarcode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(30, (index) {
        return Container(
          width: index % 2 == 0 ? 4.0 : 2.0,
          height: 40.0,
          color: index % 2 == 0 ? subTheme : Colors.white,
        );
      }),
    );
  }
}
