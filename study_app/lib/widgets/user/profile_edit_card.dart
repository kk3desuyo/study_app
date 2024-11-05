import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreパッケージをインポート
import 'package:study_app/theme/color.dart'; // subThemeをインポート

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
  late TextEditingController tag1Controller;
  late TextEditingController tag2Controller;

  late List<Tag> tags;

  @override
  void initState() {
    super.initState();

    tags = List<Tag>.from(widget.tags);

    if (tags.length < 2) {
      int tagsToAdd = 2 - tags.length;
      for (int i = 0; i < tagsToAdd; i++) {
        tags.add(Tag(name: "", isAchievement: false));
      }
    }

    nameController = TextEditingController(text: widget.name);
    oneWordController = TextEditingController(text: widget.oneWord);
    tag1Controller = TextEditingController(text: tags[0].name);
    tag2Controller = TextEditingController(text: tags[1].name);

    tag1IsAchievement = tags[0].isAchievement;
    tag2IsAchievement = tags[1].isAchievement;
  }

  @override
  void dispose() {
    nameController.dispose();
    oneWordController.dispose();
    tag1Controller.dispose();
    tag2Controller.dispose();
    super.dispose();
  }

  void setIsAchievement(int tagNumber, bool newIsAchievement) {
    setState(() {
      if (tagNumber == 1) {
        tag1IsAchievement = newIsAchievement;
      } else {
        tag2IsAchievement = newIsAchievement;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.profileImgUrl.isNotEmpty
                        ? NetworkImage(widget.profileImgUrl)
                        : null,
                    child: widget.profileImgUrl.isEmpty
                        ? Icon(Icons.person, size: 50)
                        : null,
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
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'タグ1',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: subTheme),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: subTheme),
                            ),
                          ),
                          controller: tag1Controller,
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
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'タグ2',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: subTheme),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: subTheme),
                            ),
                          ),
                          controller: tag2Controller,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: subTheme),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          widget.onChanged();
                          String updatedName = nameController.text;
                          String updatedOneWord = oneWordController.text;

                          Tag updatedTag1 = Tag(
                            name: tag1Controller.text,
                            isAchievement: tag1IsAchievement,
                          );

                          Tag updatedTag2 = Tag(
                            name: tag2Controller.text,
                            isAchievement: tag2IsAchievement,
                          );

                          List<Tag> updatedTags = [updatedTag1, updatedTag2];

                          await UserService().updateUserProfile(
                            name: updatedName,
                            oneWord: updatedOneWord,
                            newTags: updatedTags,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('プロフィールを更新しました')),
                          );
                          Navigator.of(context).pop();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
