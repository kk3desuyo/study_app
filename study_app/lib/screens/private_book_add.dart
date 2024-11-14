// Import necessary packages
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_app/services/book_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/home/tab_bar.dart';

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
  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryId;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCachedImage(); // Load cached image on start
    fetchCategories(); // Fetch categories from Firestore
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

  // Load cached image if any
  Future<void> _loadCachedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/cached_image.png');
    if (await file.exists()) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      // Save the picked image to cache
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File newImage =
          await File(pickedFile.path).copy('$path/cached_image.png');
      setState(() {
        _selectedImage = newImage;
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
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text("教材情報を入力"),
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
                          onTap: _pickImage,
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
                        height: 100,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedCategoryId,
                                    hint: Text(
                                      'カテゴリーを選択',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategoryId = newValue;
                                      });
                                    },
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category['categoryId'],
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 8.0),
                                          child: Text(
                                            category['category'] ?? '',
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
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
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
                      SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_selectedImage != null &&
                                _titleController.text.isNotEmpty) {
                              // Get the current user ID (make sure the user is logged in)
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                final userId = user.uid;

                                // Save the image to cache or storage and get the image URL or path
                                final directory =
                                    await getApplicationDocumentsDirectory();
                                final path = directory.path;
                                String uniqueFileName =
                                    'image_${DateTime.now().millisecondsSinceEpoch}.png';
                                final savedImage = await _selectedImage!
                                    .copy('$path/$uniqueFileName');

                                // If you have storage setup, you might upload the image and get a URL
                                // For simplicity, we'll use the local path here
                                String imgUrl = savedImage.path;

                                // Get the title
                                String title = _titleController.text.trim();

                                // Get or create the category
                                String categoryName = '';
                                if (_tabController.index == 1 &&
                                    _newCategoryController.text
                                        .trim()
                                        .isNotEmpty) {
                                  // User is adding a new category
                                  categoryName =
                                      _newCategoryController.text.trim();
                                  // Save new category to Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('categories')
                                      .add({'category': categoryName});
                                  // Refresh the category list
                                  await fetchCategories();
                                } else if (selectedCategoryId != null) {
                                  // User selected an existing category
                                  categoryName = categories.firstWhere(
                                      (category) =>
                                          category['categoryId'] ==
                                          selectedCategoryId)['category'];
                                } else {
                                  // No category selected
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('カテゴリーを選択してください。')),
                                  );
                                  return;
                                }

                                // Generate a unique book ID
                                String bookId =
                                    'book_${DateTime.now().millisecondsSinceEpoch}';

                                // Get the current date
                                DateTime lastUsedDate = DateTime.now();
                                BookService bookService = BookService();
                                try {
                                  await bookService.addPrivateBookToUser(
                                    userId,
                                    bookId,
                                    lastUsedDate,
                                    categoryName,
                                    imgUrl,
                                    title,
                                  );

                                  // Show a confirmation message or navigate
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('教材が保存されました！')),
                                  );

                                  // Optionally, clear the fields
                                  setState(() {
                                    _selectedImage = null;
                                    _titleController.clear();
                                    _newCategoryController.clear();
                                    selectedCategoryId = null;
                                  });
                                } catch (e) {
                                  // Handle errors
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('保存中にエラーが発生しました: $e')),
                                  );
                                }
                              } else {
                                // Handle the case when the user is not logged in
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('ログインしてください。')),
                                );
                              }
                            } else {
                              // Handle the case when image or title is missing
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('画像とタイトルを入力してください。')),
                              );
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
    );
  }
}
