// lib/screens/custom_book_entry_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_app/services/book_service.dart';

import 'package:study_app/services/img_upload/image_upload_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:http/http.dart' as http;

// Custom Tab Indicator Class
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

class CustomBookEntryScreen extends StatefulWidget {
  @override
  _CustomBookEntryScreenState createState() => _CustomBookEntryScreenState();
}

class _CustomBookEntryScreenState extends State<CustomBookEntryScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final _titleController = TextEditingController();
  final _newCategoryController = TextEditingController();
  List<Map<String, String>> categories = [];
  String? selectedCategoryId;
  bool isLoading = true;
  bool isSaving = false; // 保存処理中かどうかのフラグ
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  final ImageUploadService _imageUploadService = ImageUploadService(); // 追加

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchCategories(); // Firestoreからカテゴリーを取得
  }

  Future<void> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        CollectionReference categoriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('categories');

        QuerySnapshot snapshot = await categoriesCollection.get();

        setState(() {
          categories = snapshot.docs.map((doc) {
            return {
              'categoryId': doc.id,
              'category': doc['category'] as String,
            };
          }).toList();

          // 「カテゴリーなし」が存在するか確認し、存在しなければ追加
          if (!categories
              .any((category) => category['categoryId'] == 'no_category')) {
            categories.insert(0, {
              'categoryId': 'no_category',
              'category': 'カテゴリーなし',
            });
          }

          // デフォルトで「カテゴリーなし」を選択
          selectedCategoryId = 'no_category';

          print("カテゴリー一覧:");
          for (var category in categories) {
            print(
                'Category ID: ${category['categoryId']}, Category: ${category['category']}');
          }

          isLoading = false;
        });
      } catch (e) {
        print("カテゴリー取得エラー: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("ユーザーがログインしていません");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ギャラリーから画像を選択
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newCategoryController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 戻るボタンの制御
      onWillPop: () async => !isSaving, // isSavingがfalseの場合のみ戻れる
      child: Scaffold(
        backgroundColor: backGroundColor,
        appBar: AppBar(
          title: Text("教材情報を入力"),
          automaticallyImplyLeading: !isSaving, // 保存中は戻るボタンを非表示
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  margin: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: isSaving ? null : _pickImage, // 保存中はタップ不可
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : AssetImage(
                                              'assets/images/default_book_img.jpg')
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _selectedImage == null
                                  ? Icon(Icons.add_a_photo,
                                      size: 30, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 25),
                              decoration: BoxDecoration(
                                color: subTheme,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'タイトル',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: "KiwiMaru-Regular"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "教材のタイトルを入力してください",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                        SizedBox(
                          height: 150,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value:
                                          selectedCategoryId, // 現在選択中のcategoryIdを設定
                                      hint: Text(
                                        'カテゴリーを選択',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      onChanged: (String? newValue) {
                                        print(newValue);
                                        setState(() {
                                          selectedCategoryId =
                                              newValue; // 選択されたIDを保持
                                        });
                                      },
                                      items: categories.map((category) {
                                        return DropdownMenuItem<String>(
                                          value: category[
                                              'categoryId'], // valueにはcategoryIdを設定
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              category['category'] ??
                                                  '', // 表示にはcategoryNameを使用
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: subTheme, width: 1.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      dropdownColor: Colors.white,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey[700],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _newCategoryController,
                                      decoration: InputDecoration(
                                        labelText: '新しいカテゴリー名',
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: subTheme),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              String newCategory =
                                                  _newCategoryController.text
                                                      .trim();
                                              if (newCategory.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'カテゴリー名を入力してください。')),
                                                );
                                                return;
                                              }

                                              setState(() {
                                                isSaving = true;
                                              });

                                              try {
                                                // Firestoreに新しいカテゴリーを追加
                                                DocumentReference
                                                    newCategoryRef =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection(
                                                            'categories')
                                                        .add({
                                                  'category': newCategory
                                                });

                                                // カテゴリーリストを更新
                                                await fetchCategories();
                                                setState(() {
                                                  selectedCategoryId =
                                                      newCategoryRef.id;
                                                  _newCategoryController
                                                      .clear();
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'カテゴリーが追加されました。')),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'カテゴリーの追加に失敗しました: $e')),
                                                );
                                              } finally {
                                                setState(() {
                                                  isSaving = false;
                                                });
                                              }
                                            },
                                      child: Text("カテゴリーを追加"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: subTheme,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (isSaving)
                          CircularProgressIndicator() // 保存中はローディングアニメーションを表示
                        else
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isSaving = true; // 保存処理開始
                                });

                                UserService userService = UserService();
                                String? userId = userService.getCurrentUserId();

                                if (_titleController.text.isNotEmpty) {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    try {
                                      String? imageUrl;

                                      if (_selectedImage != null) {
                                        // 画像をアップロードサービスで処理
                                        imageUrl = await _imageUploadService
                                            .uploadImage(
                                                _selectedImage!, 'bookImg');
                                      } else {
                                        // デフォルト画像の場合、既存の画像URLを使用
                                        imageUrl = 'デフォルト画像のURL'; // 必要に応じて修正
                                      }

                                      // カテゴリー取得または作成
                                      String categoryName = '';
                                      if (_tabController.index == 1 &&
                                          _newCategoryController.text
                                              .trim()
                                              .isNotEmpty) {
                                        // 新しいカテゴリーを追加
                                        categoryName =
                                            _newCategoryController.text.trim();
                                        DocumentReference newCategoryRef =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .collection('categories')
                                                .add(
                                                    {'category': categoryName});
                                        // カテゴリーリストを更新
                                        await fetchCategories();
                                        setState(() {
                                          selectedCategoryId =
                                              newCategoryRef.id;
                                        });
                                      } else if (selectedCategoryId != null) {
                                        // 既存のカテゴリーを選択
                                        categoryName = categories
                                            .firstWhere((category) =>
                                                category['categoryId'] ==
                                                selectedCategoryId)['category']!
                                            .toString();
                                      } else {
                                        // カテゴリーが選択されていない場合
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('カテゴリーを選択してください。')),
                                        );
                                        setState(() {
                                          isSaving = false; // 保存処理終了
                                        });
                                        return;
                                      }

                                      // タイトル取得
                                      String title =
                                          _titleController.text.trim();
                                      if (userId == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('ユーザーIDが取得できませんでした。')),
                                        );
                                        setState(() {
                                          isSaving = false; // 保存処理終了
                                        });
                                        return;
                                      }

                                      print("カテゴリーID: $selectedCategoryId");

                                      BookService bookService = BookService();
                                      await bookService.addPrivateBookToUser(
                                          userId,
                                          selectedCategoryId ?? 'no_category',
                                          imageUrl,
                                          title);

                                      // 保存成功時の処理
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('教材が保存されました！')),
                                      );

                                      // フィールドのクリア
                                      setState(() {
                                        _selectedImage = null;
                                        _titleController.clear();
                                        _newCategoryController.clear();
                                        selectedCategoryId = 'no_category';
                                        isSaving = false; // 保存処理終了
                                      });

                                      // 前の画面に戻る
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      // エラー時の処理
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('保存中にエラーが発生しました: $e')),
                                      );
                                      setState(() {
                                        isSaving = false; // 保存処理終了
                                      });
                                    }
                                  } else {
                                    // ユーザーがログインしていない場合の処理
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('ログインしてください。')),
                                    );
                                    setState(() {
                                      isSaving = false; // 保存処理終了
                                    });
                                  }
                                } else {
                                  // タイトルが入力されていない場合の処理
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('タイトルを入力してください。')),
                                  );
                                  setState(() {
                                    isSaving = false; // 保存処理終了
                                  });
                                }
                              },
                              child: Text("教材を保存",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: subTheme,
                                    fontWeight: FontWeight.bold,
                                  )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: subTheme, width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
