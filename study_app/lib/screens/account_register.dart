// lib/widgets/account_register.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/main.dart';
import 'package:study_app/models/tag_modale.dart';
import 'package:study_app/services/img_upload/image_upload_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart'; // subThemeをインポート
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/screens/tag_selection.dart';

class AccountRegister extends StatefulWidget {
  String name = '';
  String oneWord = '';
  List<Tag> tags = [];
  String profileImgUrl = '';

  @override
  _AccountRegisterState createState() => _AccountRegisterState();
}

class _AccountRegisterState extends State<AccountRegister> {
  final UserService userService = UserService();
  late bool tag1IsAchievement;
  late bool tag2IsAchievement;

  late TextEditingController nameController;
  late TextEditingController oneWordController;
  bool isPublic = false;
  late List<Tag> tags;
  String? nameErrorMessage; // Error message for empty name

  List<Map<String, dynamic>> categories = [];
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    // コントローラーの初期化
    nameController = TextEditingController();
    oneWordController = TextEditingController();

    // 初期値の設定
    tag1IsAchievement = false;
    tag2IsAchievement = false;
    tags = [
      Tag(id: '', name: '', isAchievement: false),
      Tag(id: '', name: '', isAchievement: false),
    ];

    loadCategoriesAndTags();
  }

  Future<void> loadCategoriesAndTags() async {
    String data =
        await rootBundle.loadString('assets/data/categories_and_tags.json');
    List<dynamic> jsonResult = json.decode(data);
    setState(() {
      categories = jsonResult.cast<Map<String, dynamic>>();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    oneWordController.dispose();
    super.dispose();
  }

  Future<void> _togglePublic(bool value) async {
    try {
      setState(() {
        isPublic = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${value ? '公開' : '非公開'}に設定しました')),
      );
    } catch (e) {
      print('Error toggling public setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('公開設定の更新に失敗しました')),
      );
    }
  }

  void setIsAchievement(int tagNumber, bool newIsAchievement) {
    setState(() {
      if (tagNumber == 1) {
        tag1IsAchievement = newIsAchievement;
        tags[0] = Tag(
          id: tags[0].id,
          name: tags[0].name,
          isAchievement: newIsAchievement,
        );
      } else {
        tag2IsAchievement = newIsAchievement;
        tags[1] = Tag(
          id: tags[1].id,
          name: tags[1].name,
          isAchievement: newIsAchievement,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (widget.profileImgUrl.isNotEmpty
                                  ? NetworkImage(widget.profileImgUrl)
                                  : null) as ImageProvider<Object>?,
                          child: (_selectedImage == null &&
                                  widget.profileImgUrl.isEmpty)
                              ? Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: '名前',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: subTheme),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: subTheme),
                          ),
                          errorText: nameErrorMessage, // Show error if any
                        ),
                        controller: nameController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'ひとこと',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: subTheme),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: subTheme),
                          ),
                        ),
                        controller: oneWordController,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                            ),
                            onPressed: () {
                              setIsAchievement(1, !tag1IsAchievement);
                            },
                            child: Row(
                              children: tag1IsAchievement
                                  ? [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 21,
                                      ),
                                      Text(
                                        '達成済み',
                                        style: TextStyle(color: subTheme),
                                      ),
                                    ]
                                  : [
                                      Icon(
                                        Icons.drive_file_rename_outline,
                                        color: Colors.blue,
                                        size: 23,
                                      ),
                                      Text(
                                        '   勉強中',
                                        style: TextStyle(color: subTheme),
                                      ),
                                    ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TagSelectionScreen(
                                    tagNumber: 1,
                                    categories: categories,
                                    onTagSelected:
                                        (selectedTagNumber, selectedTag) {
                                      setState(() {
                                        if (selectedTagNumber == 1) {
                                          tags[0] = Tag(
                                            id: selectedTag['id'],
                                            name: selectedTag['name'],
                                            isAchievement: tag1IsAchievement,
                                          );
                                        } else {
                                          tags[1] = Tag(
                                            id: selectedTag['id'],
                                            name: selectedTag['name'],
                                            isAchievement: tag2IsAchievement,
                                          );
                                        }
                                      });
                                    },
                                  ), // 遷移先の画面
                                  withNavBar: false, // ナビゲーションバーを非表示にする
                                  pageTransitionAnimation:
                                      PageTransitionAnimation
                                          .cupertino, // アニメーションの種類
                                )
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: subTheme),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                tags[0].name.isNotEmpty
                                    ? tags[0].name
                                    : 'タグ1を選択',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                            ),
                            onPressed: () {
                              setIsAchievement(2, !tag2IsAchievement);
                            },
                            child: Row(
                              children: tag2IsAchievement
                                  ? [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 21,
                                      ),
                                      Text(
                                        '達成済み',
                                        style: TextStyle(color: subTheme),
                                      ),
                                    ]
                                  : [
                                      Icon(
                                        Icons.drive_file_rename_outline,
                                        color: Colors.blue,
                                        size: 23,
                                      ),
                                      Text(
                                        '   勉強中',
                                        style: TextStyle(color: subTheme),
                                      ),
                                    ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: TagSelectionScreen(
                                    tagNumber: 2,
                                    categories: categories,
                                    onTagSelected:
                                        (selectedTagNumber, selectedTag) {
                                      setState(() {
                                        if (selectedTagNumber == 1) {
                                          tags[0] = Tag(
                                            id: selectedTag['id'],
                                            name: selectedTag['name'],
                                            isAchievement: tag1IsAchievement,
                                          );
                                        } else {
                                          tags[1] = Tag(
                                            id: selectedTag['id'],
                                            name: selectedTag['name'],
                                            isAchievement: tag2IsAchievement,
                                          );
                                        }
                                      });
                                    },
                                  ), // 遷移先の画面
                                  withNavBar: false, // ナビゲーションバーを非表示にする
                                  pageTransitionAnimation:
                                      PageTransitionAnimation
                                          .cupertino, // アニメーションの種類
                                ),
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: subTheme),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                tags[1].name.isNotEmpty
                                    ? tags[1].name
                                    : 'タグ2を選択',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.public, size: 40),
                          title: Text(
                            'アカウントの公開',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text('アカウントを公開・非公開に設定します',
                              style: TextStyle(fontSize: 12)),
                          trailing: Switch(
                            value: isPublic,
                            onChanged: _togglePublic,
                            activeColor: subTheme,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: subTheme),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            setState(() {
                              nameErrorMessage = '名前を入力してください';
                            });
                            return; // Stop if name is empty
                          }

                          // Clear the error if validation passes
                          setState(() {
                            nameErrorMessage = null;
                          });

                          String updatedName = nameController.text.trim();
                          String updatedOneWord = oneWordController.text.trim();

                          // Validate that tags are selected
                          if (tags[0].id.isEmpty || tags[1].id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('タグを選択してください')),
                            );
                            return;
                          }

                          // Handle image upload if changed
                          String? imageUrl = widget.profileImgUrl;
                          ImageUploadService imageService =
                              ImageUploadService();
                          if (_imageChanged && _selectedImage != null) {
                            // 画像をアップロード
                            imageUrl = await imageService.uploadImage(
                                _selectedImage!, 'icon');
                          }

                          List<Tag> updatedTags = tags;

                          await userService.firstUserProfileAdd(
                            name: updatedName,
                            oneWord: updatedOneWord,
                            newTags: updatedTags,
                            isPublic: isPublic,
                            profileImgUrl: imageUrl,
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text(
                          '登録',
                          style: TextStyle(
                              color: subTheme,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
