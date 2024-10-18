import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class MyAppBarPrev extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBarPrev({Key? key}) : super(key: key);

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
      title: const Text(
        "今日のレポート",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: primary),
      ),
      actions: [], // アイコンを削除
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarPrev(),
      resizeToAvoidBottomInset: false, // キーボード表示時に他のUI要素が動かないようにする
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 他のUI要素
            ElevatedButton(
              onPressed: () {
                // ボタンのアクション
              },
              child: Text("Clock Button"), // 中央のボタン
            ),
          ],
        ),
      ),
    );
  }
}
