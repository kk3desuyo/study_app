// auth.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_app/logo.dart';
import 'package:study_app/main.dart';
import 'package:study_app/screens/account_register.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart'; // 色のテーマ
import 'package:study_app/screens/home.dart';
import 'package:study_app/widgets/controller_manager.dart'; // Home ウィジェットへの正しいパスを指定

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ログイン用
  final TextEditingController _emailControllerLogin = TextEditingController();
  final TextEditingController _passwordControllerLogin =
      TextEditingController();
  String _errorMessageLogin = '';

  // 登録用
  final TextEditingController _emailControllerRegister =
      TextEditingController();
  final TextEditingController _passwordControllerRegister =
      TextEditingController();
  final TextEditingController _confirmPasswordControllerRegister =
      TextEditingController(); // 確認用パスワードコントローラー
  String _errorMessageRegister = '';
  bool _isPasswordMatching = true; // パスワード一致フラグ

  // パスワード表示切替フラグ
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isRegisterConfirmPasswordVisible = false;

  // パスワード強度
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.red;

  // ログイン関数
  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailControllerLogin.text.trim(),
        password: _passwordControllerLogin.text.trim(),
      );

      // メールアドレスの確認状態をチェック
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        setState(() {
          _errorMessageLogin = 'メールアドレスが未確認です。確認メールを再送信しました。';
        });
        await _auth.signOut(); // 認証されていない場合はサインアウト
        return;
      }

      // 認証状態が変化し、Homeウィジェットが再ビルドされる
      setState(() {
        _errorMessageLogin = '';
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessageLogin = e.message ?? 'エラーが発生しました';
      });
    }
  }

  // 登録関数
  Future<void> _register() async {
    setState(() {
      _errorMessageRegister = '';
    });

    // パスワードと確認用パスワードが一致しているか再確認
    if (_passwordControllerRegister.text.trim() !=
        _confirmPasswordControllerRegister.text.trim()) {
      setState(() {
        _errorMessageRegister = 'パスワードが一致しません';
      });
      return;
    }

    // パスワードの強度を再確認
    if (!_isPasswordStrong(_passwordControllerRegister.text.trim())) {
      // エラーメッセージは _isPasswordStrong 内で設定されます
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailControllerRegister.text.trim(),
        password: _passwordControllerRegister.text.trim(),
      );

      // 認証メールを送信
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        setState(() {
          _errorMessageRegister = '確認メールを送信しました。メールを確認して認証を完了してください。';
        });
        // メール認証確認モーダルを表示
        _showEmailVerificationModal();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessageRegister = e.message ?? 'エラーが発生しました';
      });
    }
  }

  // パスワード強度チェック関数
  bool _isPasswordStrong(String password) {
    bool isStrong = true;

    // パスワードが8文字以上であること
    if (password.length < 8) {
      setState(() {
        _errorMessageRegister = 'パスワードは8文字以上で入力してください';
      });
      isStrong = false;
    }
    // 少なくとも1つの大文字が含まれていること
    if (!password.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        _errorMessageRegister = 'パスワードは少なくとも1つの大文字を含めてください';
      });
      isStrong = false;
    }
    // 少なくとも1つの数字が含まれていること
    if (!password.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _errorMessageRegister = 'パスワードは少なくとも1つの数字を含めてください';
      });
      isStrong = false;
    }
    // 少なくとも1つの特殊文字が含まれていること
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() {
        _errorMessageRegister =
            'パスワードは少なくとも1つの特殊文字を含めてください ex.!@#%^&*(),.?":{}|<>';
      });
      isStrong = false;
    }

    return isStrong;
  }

  // パスワード強度を評価する関数
  void _evaluatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
      });
      return;
    }

    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 1:
        setState(() {
          _passwordStrength = '非常に弱い';
          _passwordStrengthColor = Colors.red;
        });
        break;
      case 2:
        setState(() {
          _passwordStrength = '弱い';
          _passwordStrengthColor = Colors.orange;
        });
        break;
      case 3:
        setState(() {
          _passwordStrength = '強い';
          _passwordStrengthColor = Colors.lightGreen;
        });
        break;
      case 4:
        setState(() {
          _passwordStrength = '非常に強い';
          _passwordStrengthColor = Colors.green;
        });
        break;
      default:
        setState(() {
          _passwordStrength = '';
        });
    }
  }

  // メール認証確認モーダルを表示する関数
  void _showEmailVerificationModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // モーダル外をタップして閉じられないようにする
      builder: (BuildContext context) {
        String modalErrorMessage = ''; // モーダル内で使用するエラーメッセージ

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'メールアドレスの確認',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('登録したメールアドレスに確認メールを送信しました。メールを確認し、認証を完了してください。'),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // ユーザー情報を再読み込みして、メール認証済みかチェック
                      await _auth.currentUser?.reload();
                      var user = _auth.currentUser;
                      if (user != null && user.emailVerified) {
                        UserService userService = UserService();
                        await userService.addUser();
                        Navigator.pop(context); // モーダルを閉じる
                        // 認証状態が変化し、Homeウィジェットが再ビルドされる
                      } else {
                        print("メール認証が完了していません");
                        setState(() {
                          modalErrorMessage = 'メールアドレスの確認が完了していません。';
                        });
                      }
                    },
                    child: Text('メール認証しました',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subTheme,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      // 確認メールを再送信
                      await _auth.currentUser?.sendEmailVerification();
                      setState(() {
                        modalErrorMessage = '確認メールを再送信しました。';
                      });
                    },
                    child: Text('確認メールを再送信する',
                        style: TextStyle(
                            color: subTheme, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () async {
                      // 現在のユーザーを削除
                      await _auth.currentUser?.delete();
                      Navigator.pop(context); // モーダルを閉じる
                    },
                    child: Text(
                      '別のメールアドレスを登録',
                      style: TextStyle(
                          color: subTheme, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (modalErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        modalErrorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Googleサインイン関数
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _errorMessageLogin = '';
        _errorMessageRegister = '';
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // ユーザーが新規か既存かを判定
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // データベースにユーザー情報を保存
        if (userCredential.user != null) {
          UserService userService = UserService();
          await userService.addUser();
        }
        // 新規ユーザーの場合、追加の登録画面に遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountRegister()),
        );
      } else {
        print("既存ユーザーです");
        final _controller = getGlobalTabController();
        _controller.jumpToTab(0); // タブを0番目に変更

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
        );
        // 既存ユーザーの場合、ホーム画面に戻る
        setState(() {
          _errorMessageLogin = '';
          _errorMessageRegister = '';
        });
      }

      // 認証状態が変化し、Homeウィジェットが再ビルドされる
      setState(() {
        _errorMessageLogin = '';
        _errorMessageRegister = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessageLogin = e.message ?? 'ログインに失敗しました';
        _errorMessageRegister = e.message ?? 'ログインに失敗しました';
      });
    } catch (e) {
      setState(() {
        _errorMessageLogin = 'エラーが発生しました: $e';
        _errorMessageRegister = 'エラーが発生しました: $e';
      });
    }
  }

  @override
  void dispose() {
    // コントローラーの破棄
    _emailControllerLogin.dispose();
    _passwordControllerLogin.dispose();
    _emailControllerRegister.dispose();
    _passwordControllerRegister.dispose();
    _confirmPasswordControllerRegister.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面の高さを取得
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backGroundColor,
      body: Stack(children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Logo(size: 40),
            ],
          ),
        ),

        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: backGroundColor.withOpacity(0.9),
            ),
          ),
        ),
        // 中央上部にロゴを配置
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 100.0,
            ), // 上部に余白を追加
            child: Logo(size: 40), // Logoウィジェット
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: DefaultTabController(
            length: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.zero,
              child: Card(
                margin: EdgeInsets.zero, // Card の余白をなくす
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                color: Colors.white,
                elevation: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 追加部分開始

                    // 追加部分終了
                    TabBar(
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'ログイン'),
                        Tab(text: '新規登録'),
                      ],
                      labelColor: Colors.black,
                      indicatorColor: subTheme,
                    ),
                    SizedBox(
                      height: screenHeight * 0.65, // 画面高さの65%に設定
                      child: TabBarView(
                        children: [
                          // ログインタブ
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: _emailControllerLogin,
                                    decoration: InputDecoration(
                                      labelText: 'メールアドレス',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: 15),
                                  TextField(
                                    controller: _passwordControllerLogin,
                                    decoration: InputDecoration(
                                      labelText: 'パスワード',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isLoginPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isLoginPasswordVisible =
                                                !_isLoginPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: !_isLoginPasswordVisible,
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _signIn,
                                    child: Text(
                                      'ログイン',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: subTheme,
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text("または"),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 20.0,
                                        ),
                                        label: Text('Google'),
                                        onPressed: _signInWithGoogle,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: Size(130, 40),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_errorMessageLogin.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        _errorMessageLogin,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // 新規登録タブ
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: _emailControllerRegister,
                                    decoration: InputDecoration(
                                      labelText: 'メールアドレス',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: 15),
                                  TextField(
                                    controller: _passwordControllerRegister,
                                    decoration: InputDecoration(
                                      labelText: 'パスワード',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isRegisterPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isRegisterPasswordVisible =
                                                !_isRegisterPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: !_isRegisterPasswordVisible,
                                    onChanged: (value) {
                                      _evaluatePasswordStrength(value);
                                    },
                                  ),
                                  // パスワード強度インジケーター
                                  if (_passwordStrength.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'パスワード強度: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _passwordStrength,
                                            style: TextStyle(
                                              color: _passwordStrengthColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 15),
                                  TextField(
                                    controller:
                                        _confirmPasswordControllerRegister,
                                    decoration: InputDecoration(
                                      labelText: 'パスワード再入力',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: subTheme),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: subTheme),
                                      ),
                                      errorText: _isPasswordMatching
                                          ? null
                                          : 'パスワードが一致しません',
                                    ),
                                    obscureText:
                                        !_isRegisterConfirmPasswordVisible,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPasswordMatching = value ==
                                            _passwordControllerRegister.text;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _register, // 常に有効化
                                    child: Text(
                                      '新規登録',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: subTheme,
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text("または"),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 20.0,
                                        ),
                                        label: Text('Google'),
                                        onPressed: _signInWithGoogle,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: Size(130, 40),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_errorMessageRegister.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        _errorMessageRegister,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
