import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_app/screens/accoun_setting.dart';

import 'package:study_app/screens/auth.dart';
import 'package:study_app/screens/privacy_setting.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

class SettingsScreen extends StatelessWidget {
  // ログアウト処理を関数として定義
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ログアウト成功後にログイン画面へ遷移
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (Route<dynamic> route) => false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトしました')),
        );
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトに失敗しました: $e')),
        );
      });
    }
  }

  Future<void> _deleteAccount(BuildContext context, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 再認証
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // 再認証成功後にアカウント削除
        await user.delete();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthScreen()),
          (Route<dynamic> route) => false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('アカウントが消去されました')),
          );
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント消去に失敗しました: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text(
          '設定',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アカウント設定カード
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle, size: 40),
                    title: Text(
                      'アカウント',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('会員情報、パスワードの確認、変更'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.privacy_tip, size: 40),
                    title: Text(
                      'プライバシー',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('公開設定、ブロックユーザーの管理'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacySettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // ログアウトカード
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.exit_to_app, size: 40, color: Colors.black),
                    title: Text(
                      'ログアウト',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // 確認ダイアログを表示
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('ログアウト'),
                            content: Text('本当にログアウトしますか？'),
                            actions: [
                              TextButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('ログアウト'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // ダイアログを閉じる
                                  _logout(context); // ログアウト処理を実行
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete, size: 40, color: Colors.red),
                    title: Text(
                      'アカウント消去',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController _passwordController =
                              TextEditingController();
                          return AlertDialog(
                            title: Text('アカウント消去'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('アカウントを消去するためにパスワードを入力してください。'),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'パスワード',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('消去'),
                                onPressed: () async {
                                  String password =
                                      _passwordController.text.trim();
                                  if (password.isNotEmpty) {
                                    UserService userService = UserService();
                                    if (await userService
                                        .checkPassword(password)) {
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                      _deleteAccount(
                                          context, password); // アカウント削除処理を実行
                                    } else {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('パスワードが間違っています。')),
                                        );
                                      });
                                    }
                                  } else {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('パスワードを入力してください')),
                                      );
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
