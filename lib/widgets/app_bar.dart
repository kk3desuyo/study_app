import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/logo.dart';
import 'package:study_app/screens/friend_manage.dart';
import 'package:study_app/screens/setting.dart';
import 'package:study_app/theme/color.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

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
                color: Colors.orange,
              ))
          : null,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: const Logo(),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendSerch()),
              );
            },
            icon: const Icon(Icons.group, size: 33, color: primary)),
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: IconButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: SettingsScreen(), // 遷移先の画面
                  withNavBar: false, // ナビゲーションバーを非表示にする
                  pageTransitionAnimation:
                      PageTransitionAnimation.cupertino, // アニメーションの種類
                );
              },
              icon: const Icon(Icons.settings, size: 30, color: primary)),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
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
