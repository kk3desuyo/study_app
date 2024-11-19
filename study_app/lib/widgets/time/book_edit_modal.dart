import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:study_app/models/book.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

/// カスタムタブインジケーターのクラス
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

class CustomBookEntryModal extends StatefulWidget {
  final Book book;
  final Function(Book) onChanged; // 編集後の教材を返すコールバック

  const CustomBookEntryModal({
    Key? key,
    required this.book,
    required this.onChanged, // コールバックを受け取る
  }) : super(key: key);

  @override
  _CustomBookEntryModalState createState() => _CustomBookEntryModalState();
}

class _CustomBookEntryModalState extends State<CustomBookEntryModal>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final _titleController = TextEditingController();
  final _newCategoryController = TextEditingController();
  List<Map<String, String>> categories = [];
  String? selectedCategoryId;
  bool isLoading = true;
  bool isSaving = false;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  // 変更前の値を保持
  late String initialTitle;
  late String initialImgUrl;
  late String initialCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book.title; // タイトルを初期化
    selectedCategoryId = widget.book.categoryId;
    initialTitle = widget.book.title;
    initialImgUrl = widget.book.imgUrl;
    initialCategoryId = widget.book.categoryId;
    _tabController = TabController(length: 2, vsync: this);
    fetchCategories();
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

          // selectedCategoryId が categories に存在しない場合、'no_category' に設定
          if (!categories.any(
              (category) => category['categoryId'] == selectedCategoryId)) {
            selectedCategoryId = 'no_category';
          }

          isLoading = false;
        });
      } catch (e) {
        print("Error fetching categories: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("User not logged in");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ギャラリーから画像を選択
  Future<void> _pickImage() async {
    if (!widget.book.isPrivate) {
      // プライベートでない場合、メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('この教材は独自教材ではないため、画像を変更できません。'),
        ),
      );
      return;
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // ローカル画像を設定
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
    // タイトルが編集可能かどうか
    bool isTitleEditable = widget.book.isPrivate;

    return isLoading
        ? Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage, // ギャラリーから画像を選択する関数
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                // ネット画像とローカル画像を切り替えるロジック
                                image: _selectedImage != null
                                    ? FileImage(_selectedImage!) // ローカル画像を優先
                                    : (widget.book.imgUrl.isNotEmpty
                                        ? NetworkImage(
                                            widget.book.imgUrl) // ネット画像
                                        : AssetImage(
                                                'assets/images/default_book_img.jpg')
                                            as ImageProvider), // デフォルト画像
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10), // 角丸の設定
                            ),
                            child: (!widget.book.isPrivate &&
                                    _selectedImage == null &&
                                    widget.book.imgUrl.isEmpty)
                                ? Icon(Icons.add_a_photo,
                                    size: 30, color: Colors.white)
                                : null, // 初期状態のカメラアイコン
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
                      GestureDetector(
                        onTap: () {
                          if (!isTitleEditable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('この教材は独自教材ではないため、タイトルを変更できません。'),
                              ),
                            );
                          }
                        },
                        child: AbsorbPointer(
                          absorbing: !isTitleEditable,
                          child: TextField(
                            controller: _titleController,
                            readOnly: !isTitleEditable,
                            decoration: InputDecoration(
                              hintText: "教材のタイトルを入力してください",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                  DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    hint: Text(
                                      'カテゴリーを選択',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category['categoryId'],
                                        child: Text(
                                          category['category'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    value: selectedCategoryId,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategoryId = newValue;
                                      });
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.only(right: 8),
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),
                                      iconSize: 24,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
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
                                        borderSide: BorderSide(color: subTheme),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
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
                        CircularProgressIndicator()
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              // 変更がなければ何もしない
                              String currentTitle =
                                  _titleController.text.trim();
                              String currentImgUrl = initialImgUrl;
                              String currentCategoryId = initialCategoryId;

                              if (widget.book.isPrivate &&
                                  _selectedImage != null) {
                                // 画像が変更された場合
                                // ここでは一時的に画像URLをnullに設定
                                currentImgUrl = '';
                              }

                              // カテゴリーの変更
                              if (_tabController.index == 1 &&
                                  _newCategoryController.text
                                      .trim()
                                      .isNotEmpty) {
                                // 新しいカテゴリーが追加された場合
                                // categoryIdは後で更新するため一時的に保持
                                currentCategoryId =
                                    selectedCategoryId ?? initialCategoryId;
                              } else if (selectedCategoryId != null) {
                                currentCategoryId = selectedCategoryId!;
                              }

                              bool isTitleChanged = widget.book.isPrivate &&
                                  currentTitle != initialTitle;
                              bool isImageChanged = widget.book.isPrivate &&
                                  (_selectedImage != null ||
                                      currentImgUrl != initialImgUrl);
                              bool isCategoryChanged =
                                  currentCategoryId != initialCategoryId;

                              if (!isTitleChanged &&
                                  !isImageChanged &&
                                  !isCategoryChanged) {
                                // 何も変更がない場合
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('変更がありません。')),
                                );
                                Navigator.of(context).pop();
                                return;
                              }

                              setState(() {
                                isSaving = true;
                              });

                              UserService userService = UserService();
                              String? userId = userService.getCurrentUserId();

                              if (currentTitle.isNotEmpty ||
                                  (!widget.book.isPrivate &&
                                      currentCategoryId.isNotEmpty)) {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  try {
                                    String? imageUrl = initialImgUrl;

                                    if (widget.book.isPrivate &&
                                        _selectedImage != null) {
                                      final compressedImage =
                                          await FlutterImageCompress
                                              .compressWithFile(
                                        _selectedImage!.path,
                                        minWidth: 800,
                                        minHeight: 600,
                                        quality: 70,
                                      );

                                      if (compressedImage != null) {
                                        String base64Image =
                                            'data:image/jpeg;base64,' +
                                                base64Encode(compressedImage);

                                        final response = await http.post(
                                          Uri.parse(
                                              'https://us-central1-study-app-6a883.cloudfunctions.net/cloudinary_function'),
                                          headers: {
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonEncode(
                                              {'image': base64Image}),
                                        );

                                        if (response.statusCode == 200) {
                                          try {
                                            final responseData =
                                                jsonDecode(response.body);
                                            imageUrl = responseData['url'];
                                          } catch (e) {
                                            throw Exception('レスポンスの解析に失敗しました。');
                                          }
                                        } else {
                                          throw Exception('画像のアップロードに失敗しました。');
                                        }

                                        if (imageUrl == null) {
                                          throw Exception('画像のアップロードに失敗しました。');
                                        }
                                      } else {
                                        throw Exception('画像の圧縮に失敗しました。');
                                      }
                                    }

                                    String categoryName = '';
                                    String? finalCategoryId = currentCategoryId;

                                    if (_tabController.index == 1 &&
                                        _newCategoryController.text
                                            .trim()
                                            .isNotEmpty) {
                                      categoryName =
                                          _newCategoryController.text.trim();
                                      DocumentReference newCategoryRef =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userId)
                                              .collection('categories')
                                              .add({'category': categoryName});
                                      await fetchCategories();
                                      setState(() {
                                        finalCategoryId = newCategoryRef.id;
                                      });
                                    } else if (selectedCategoryId != null) {
                                      categoryName = categories.firstWhere(
                                          (category) =>
                                              category['categoryId'] ==
                                              selectedCategoryId)['category']!;
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('カテゴリーを選択してください。')),
                                      );
                                      setState(() {
                                        isSaving = false;
                                      });
                                      return;
                                    }

                                    String title = currentTitle;
                                    if (userId == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('ユーザーIDが取得できませんでした。')),
                                      );
                                      setState(() {
                                        isSaving = false;
                                      });
                                      return;
                                    }

                                    BookService bookService = BookService();
                                    await bookService.updatePrivateBook(
                                      widget.book.id,
                                      title: title, // 更新されたタイトルを使用
                                      imgUrl: imageUrl, // 更新された imgUrl を使用
                                      categoryId:
                                          finalCategoryId!, // 更新された categoryId を使用
                                      lastUsedDate:
                                          DateTime.now(), // 更新日時を現在に設定
                                    );

                                    // 編集された本の最新データを取得
                                    Book updatedBook = Book(
                                      id: widget.book.id,
                                      title: title,
                                      imgUrl: imageUrl,
                                      categoryId:
                                          finalCategoryId ?? 'no_category',
                                      category: categoryName,
                                      lastUsedDate: DateTime.now(),
                                      isPrivate:
                                          widget.book.isPrivate, // isPrivateを保持
                                    );

                                    // コールバックで親に通知
                                    widget.onChanged(updatedBook);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('教材が保存されました！')),
                                    );

                                    setState(() {
                                      _selectedImage = null;
                                      if (widget.book.isPrivate) {
                                        _titleController.clear();
                                      }
                                      _newCategoryController.clear();
                                      selectedCategoryId = 'no_category';
                                      isSaving = false;
                                    });

                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('保存中にエラーが発生しました: $e')),
                                    );
                                    setState(() {
                                      isSaving = false;
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('ログインしてください。')),
                                  );
                                  setState(() {
                                    isSaving = false;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('タイトルを入力してください。')),
                                );
                                setState(() {
                                  isSaving = false;
                                });
                              }
                            },
                            child: Text("保存",
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
          );
  }
}
