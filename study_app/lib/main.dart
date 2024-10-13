import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/screens/home.dart';
import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/screens/time.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // 英語
        const Locale('ja'), // 日本語
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // AppBarの背景色を白に
          elevation: 0, // AppBarの影をなくす
        ),
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // PersistentTabControllerのインスタンスを作成
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    // 初期化時にコントローラを設定
    _controller = PersistentTabController(initialIndex: 2); // 2は真ん中のボタンに対応
  }

  var _pages = <Widget>[
    HomeScreen(),
    PreviewDetailScreen(),
    TimePage(), // 真ん中のタブに表示するページ
    HomeScreen(),
    HomeScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent layout resize when keyboard appears
      body: Stack(
        children: [
          PersistentTabView(
            context,
            controller: _controller,
            screens: _pages,
            items: [
              PersistentBottomNavBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Icon(
                      Icons.home,
                      size: 33,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'ホーム',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                activeColorPrimary: primary,
                inactiveColorPrimary: Colors.grey,
              ),
              PersistentBottomNavBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Icon(
                      Icons.stacked_bar_chart,
                      size: 33,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'レポート',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                activeColorPrimary: primary,
                inactiveColorPrimary: Colors.grey,
              ),
              PersistentBottomNavBarItem(
                icon: SizedBox.shrink(),
              ),
              PersistentBottomNavBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Icon(
                      Icons.notifications,
                      size: 33,
                    ),
                    SizedBox(height: 1),
                    Text(
                      '通知',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                activeColorPrimary: primary,
                inactiveColorPrimary: Colors.grey,
              ),
              PersistentBottomNavBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Icon(
                      Icons.person,
                      size: 33,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'アカウント',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                activeColorPrimary: primary,
                inactiveColorPrimary: Colors.grey,
              ),
            ],
            navBarStyle: NavBarStyle.style15,
            backgroundColor: Colors.white,
          ),
          Positioned(
            bottom: kBottomNavigationBarHeight - 10,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () {
                _controller.jumpToTab(2);
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.access_time,
                  size: 55.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
