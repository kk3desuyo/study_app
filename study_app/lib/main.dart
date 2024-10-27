import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:study_app/firebase_options.dart';
import 'package:study_app/screens/auth.dart';
import 'package:study_app/screens/home.dart';

import 'package:study_app/screens/notification.dart';
import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/screens/time.dart';
import 'package:study_app/theme/color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:badges/badges.dart' as custom_badge;
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        const Locale('en'),
        const Locale('ja'),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
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
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 2);
  }

  Future<bool> _checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  var _pages = <Widget>[
    HomeScreen(),
    HomeScreen(),
    TimePage(),
    NotificationPage(),
    HomeScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
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
                            'ランキング',
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
                      icon: custom_badge.Badge(
                        position:
                            custom_badge.BadgePosition.topEnd(top: -5, end: -5),
                        badgeContent: Text(
                          '3',
                          style: TextStyle(color: Colors.white),
                        ),
                        badgeColor: Colors.red,
                        child: Column(
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
                        color: primary,
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
        } else {
          return AuthScreen(); // Replace with your actual auth screen
        }
      },
    );
  }
}
