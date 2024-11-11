// lib/screens/privacy_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/models/user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:study_app/theme/color.dart';

class PrivacySettingsScreen extends StatefulWidget {
  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final UserService userService = UserService();
  bool isPublic = false;
  bool isLoading = true;
  List<User> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      // 現在のユーザーの公開設定を取得
      bool currentIsPublic = await userService.getIsPublic();

      // ブロックされているユーザーのリストを取得
      List<User> currentBlockedUsers = await userService.getBlockedUsersList();

      setState(() {
        isPublic = currentIsPublic;
        blockedUsers = currentBlockedUsers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading privacy settings: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('設定の読み込みに失敗しました')),
      );
    }
  }

  Future<void> _togglePublic(bool value) async {
    try {
      await userService.setIsPublic(value);
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

  Future<void> _unblockUser(String targetUserId, String userName) async {
    try {
      await userService.unblockUser(targetUserId);
      await _loadPrivacySettings(); // データを再取得してUIを更新
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーのブロックを解除しました')),
      );
    } catch (e) {
      print('Error unblocking user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ブロック解除に失敗しました')),
      );
    }
  }

  Future<void> _confirmUnblockUser(String targetUserId, String userName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ブロック解除'),
          content: Text('$userName のブロックを解除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('解除', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _unblockUser(targetUserId, userName);
    }
  }

  void _navigateToOtherUserDisplay(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherUserDisplay(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text(
          'プライバシー設定',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: subTheme,
                size: 50,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 公開設定セクション
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.public, size: 40),
                        title: Text(
                          'アカウントの公開',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('アカウントを公開・非公開に設定します'),
                        trailing: Switch(
                          value: isPublic,
                          onChanged: _togglePublic,
                          activeColor: Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // ブロックユーザー管理セクション
                    Text(
                      'ブロックユーザーの管理',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    blockedUsers.isEmpty
                        ? Text('現在ブロックしているユーザーはいません。')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: blockedUsers.length,
                            itemBuilder: (context, index) {
                              final user = blockedUsers[index];
                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: GestureDetector(
                                    onTap: () =>
                                        _navigateToOtherUserDisplay(user),
                                    child: CircleAvatar(
                                      backgroundImage: user.profileImgUrl != ''
                                          ? NetworkImage(user.profileImgUrl)
                                          : null,
                                      backgroundColor: subTheme,
                                      child: user.profileImgUrl == ''
                                          ? Text(user.name[0])
                                          : null,
                                    ),
                                  ),
                                  title: GestureDetector(
                                    onTap: () =>
                                        _navigateToOtherUserDisplay(user),
                                    child: Text(
                                      user.name.length > 7
                                          ? '${user.name.substring(0, 7)}...'
                                          : user.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Colors.red,
                                      minimumSize: Size(60, 40), // ボタンの大きさを指定
                                    ),
                                    onPressed: () {
                                      _confirmUnblockUser(user.id, user.name);
                                    },
                                    child: Text(
                                      'ブロック解除',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
