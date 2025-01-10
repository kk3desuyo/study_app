import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class MyAppBarUser extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  const MyAppBarUser({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context)
          ? IconButton(
              onPressed: () {
                Navigator.pop(context); // 画面を戻る
              },
              icon: Icon(
                size: 45,
                Icons.arrow_circle_left_rounded,
                color: primary,
              ))
          : null,
      backgroundColor: Colors.white,
      centerTitle: true, // タイトルを中央に配置
      title: Text(
        userName,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: primary),
      ),
      actions: [], // アイコンを削除
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
