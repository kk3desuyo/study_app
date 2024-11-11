// account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController(); // 再認証用

  bool _isLoading = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showMessage('ユーザーがログインしていません。');
      return;
    }

    String newEmail = _newEmailController.text.trim();
    String currentPassword = _currentPasswordController.text.trim();

    if (newEmail.isEmpty || currentPassword.isEmpty) {
      _showMessage('新しいメールアドレスと現在のパスワードを入力してください。');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 再認証
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // メールアドレスの更新
      await user.updateEmail(newEmail);
      await user.sendEmailVerification(); // 確認メールを送信
      _showMessage('メールアドレスを更新しました。確認メールを送信しました。');

      // 必要に応じてUIを更新
      setState(() {
        _currentPasswordController.clear();
        _newEmailController.clear();
      });
    } on FirebaseAuthException catch (e) {
      _showMessage('エラー: ${e.message}');
    } catch (e) {
      _showMessage('予期せぬエラーが発生しました。');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showMessage('ユーザーがログインしていません。');
      return;
    }

    String newPassword = _newPasswordController.text.trim();
    String currentPassword = _currentPasswordController.text.trim();

    if (newPassword.isEmpty || currentPassword.isEmpty) {
      _showMessage('新しいパスワードと現在のパスワードを入力してください。');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 再認証
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // パスワードの更新
      await user.updatePassword(newPassword);
      _showMessage('パスワードを更新しました。');

      // 必要に応じてUIを更新
      setState(() {
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      _showMessage('エラー: ${e.message}');
    } catch (e) {
      _showMessage('予期せぬエラーが発生しました。');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildUpdateEmailSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('メールアドレスの変更',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _newEmailController,
              decoration: InputDecoration(labelText: '新しいメールアドレス'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: '現在のパスワード'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEmail,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('メールアドレスを更新'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatePasswordSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('パスワードの変更',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: '新しいパスワード'),
              obscureText: true,
            ),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: '現在のパスワード'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('パスワードを更新'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'アカウント設定',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text('ユーザーがログインしていません。'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // メールアドレスの表示
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.email, size: 40),
                      title: Text(
                        'メールアドレス',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email ?? '未設定'),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildUpdateEmailSection(),
                  SizedBox(height: 16),
                  _buildUpdatePasswordSection(),
                ],
              ),
            ),
    );
  }
}
