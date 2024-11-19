// lib/widgets/profile_form.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/models/tag_modale.dart';
import 'package:study_app/services/img_upload/image_upload_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:study_app/theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_app/screens/tag_selection.dart';

class ProfileForm extends StatefulWidget {
  final String name;
  final String oneWord;
  final List<Tag> tags;
  final String profileImgUrl;
  final Function() onChanged;

  ProfileForm({
    required this.name,
    required this.oneWord,
    required this.tags,
    required this.profileImgUrl,
    required this.onChanged,
  });

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late bool tag1IsAchievement;
  late bool tag2IsAchievement;

  late TextEditingController nameController;
  late TextEditingController oneWordController;

  late List<Tag> tags;
  File? _selectedImage;
  bool _imageChanged = false;
  bool isSaving = false; // 保存中フラグ
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();

    tags = List<Tag>.from(widget.tags);

    if (tags.length < 2) {
      int tagsToAdd = 2 - tags.length;
      for (int i = 0; i < tagsToAdd; i++) {
        tags.add(Tag(id: '', name: '', isAchievement: false));
      }
    }

    nameController = TextEditingController(text: widget.name);
    oneWordController = TextEditingController(text: widget.oneWord);

    tag1IsAchievement = tags[0].isAchievement;
    tag2IsAchievement = tags[1].isAchievement;

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
    if (isSaving) return; // 保存中は画像選択不可
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageChanged = true;
      });
    }
  }

  void _openTagListModal(int tagNumber, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        var tagsList = category['tags'] as List<dynamic>;
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('タグを選択 - ${category['categoryName']}'),
              Expanded(
                child: ListView.builder(
                  itemCount: tagsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var tag = tagsList[index];
                    return ListTile(
                      title: Text(tag['name']),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          if (tagNumber == 1) {
                            tags[0] = Tag(
                              id: tag['id'],
                              name: tag['name'],
                              isAchievement: tag1IsAchievement,
                            );
                          } else {
                            tags[1] = Tag(
                              id: tag['id'],
                              name: tag['name'],
                              isAchievement: tag2IsAchievement,
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: isSaving, // 保存中は操作を無効化
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
                                  child: Text(
                                    tags[0].name.isNotEmpty
                                        ? tags[0].name
                                        : 'タグ1を選択',
                                  ),
                                  onPressed: () => {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: TagSelectionScreen(
                                            tagNumber: 1,
                                            categories: categories,
                                            onTagSelected: (selectedTagNumber,
                                                selectedTag) {
                                              setState(() {
                                                if (selectedTagNumber == 1) {
                                                  print("1");
                                                  print(selectedTag['id']);
                                                  print(selectedTag['name']);
                                                  tags[0] = Tag(
                                                    id: selectedTag['id'],
                                                    name: selectedTag['name'],
                                                    isAchievement:
                                                        tag1IsAchievement,
                                                  );
                                                } else {
                                                  print("2");
                                                  print(selectedTag['id']);
                                                  print(selectedTag['name']);
                                                  tags[1] = Tag(
                                                    id: selectedTag['id'],
                                                    name: selectedTag['name'],
                                                    isAchievement:
                                                        tag2IsAchievement,
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
                                      }),
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
                                  child: Text(
                                    tags[1].name.isNotEmpty
                                        ? tags[1].name
                                        : 'タグ2を選択',
                                  ),
                                  onPressed: () => {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: TagSelectionScreen(
                                            tagNumber: 2,
                                            categories: categories,
                                            onTagSelected: (selectedTagNumber,
                                                selectedTag) {
                                              setState(() {
                                                if (selectedTagNumber == 1) {
                                                  tags[0] = Tag(
                                                    id: selectedTag['id'],
                                                    name: selectedTag['name'],
                                                    isAchievement:
                                                        tag1IsAchievement,
                                                  );
                                                } else {
                                                  tags[1] = Tag(
                                                    id: selectedTag['id'],
                                                    name: selectedTag['name'],
                                                    isAchievement:
                                                        tag2IsAchievement,
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
                                      }),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: subTheme),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('名前を入力してください')),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isSaving = true;
                                  });

                                  try {
                                    String? imageUrl = widget.profileImgUrl;

                                    if (_imageChanged &&
                                        _selectedImage != null) {
                                      // 画像をアップロード
                                      imageUrl = await _imageUploadService
                                          .uploadImage(_selectedImage!, 'icon');
                                    }

                                    String updatedName =
                                        nameController.text.trim();
                                    String updatedOneWord =
                                        oneWordController.text.trim();

                                    List<Tag> updatedTags = tags;

                                    await UserService().updateUserProfile(
                                      name: updatedName,
                                      oneWord: updatedOneWord,
                                      newTags: updatedTags,
                                      profileImgUrl: imageUrl,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('プロフィールを更新しました')),
                                    );
                                    widget.onChanged();
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('更新中にエラーが発生しました: $e')),
                                    );
                                  } finally {
                                    setState(() {
                                      isSaving = false;
                                    });
                                  }
                                },
                          child: Text(
                            '保存',
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
        if (isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
