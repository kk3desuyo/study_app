import 'package:flutter/material.dart';
import 'package:study_app/screens/home.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/widgets/user/tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreパッケージをインポート
import 'package:study_app/theme/color.dart'; // subThemeをインポート

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
  late TextEditingController tag1Controller;
  late TextEditingController tag2Controller;
  bool isPublic = false;
  late List<Tag> tags;
  String? nameErrorMessage; // Error message for empty name

  @override
  void initState() {
    super.initState();
    // コントローラーの初期化
    nameController = TextEditingController();
    oneWordController = TextEditingController();
    tag1Controller = TextEditingController();
    tag2Controller = TextEditingController();

    // 初期値の設定（必要に応じて）
    tag1IsAchievement = false;
    tag2IsAchievement = false;
    tags = [];
  }

  @override
  void dispose() {
    nameController.dispose();
    oneWordController.dispose();
    tag1Controller.dispose();
    tag2Controller.dispose();
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
      } else {
        tag2IsAchievement = newIsAchievement;
      }
    });
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
                              if (nameController.text.isEmpty) {
                                setState(() {
                                  nameErrorMessage = '名前を入力してください';
                                });
                                return; // Stop if name is empty
                              }

                              // Clear the error if validation passes
                              setState(() {
                                nameErrorMessage = null;
                              });

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

                              List<Tag> updatedTags = [
                                updatedTag1,
                                updatedTag2
                              ];

                              await UserService().firstUserProfileAdd(
                                name: updatedName,
                                oneWord: updatedOneWord,
                                newTags: updatedTags,
                                isPublic: isPublic,
                              );

                              // Navigate back to the main Home widget to retain the tabs
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                                (route) => false,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        )));
  }
}
