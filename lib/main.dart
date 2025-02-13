import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:badges/badges.dart' as custom_badge;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:study_app/firebase_options.dart';
import 'package:study_app/screens/auth.dart';
import 'package:study_app/screens/account_register.dart';
import 'package:study_app/screens/book.dart';
import 'package:study_app/screens/home.dart';
import 'package:study_app/screens/my_account.dart';
import 'package:study_app/screens/notification.dart';
import 'package:study_app/screens/rank_screen.dart';
import 'package:study_app/screens/time.dart';
import 'package:study_app/services/sync_service.dart';
import 'package:study_app/services/user/app/app_service.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/controller_manager.dart';

// Firebase Messagingのバックグラウンドメッセージハンドラー
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('バックグラウンドでメッセージを受信しました: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Messagingのバックグラウンドハンドラー設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Hive初期化
  await Hive.initFlutter();

  try {
    await Hive.openBox('studyRecords'); // Hive Boxを開く
  } catch (e) {
    print('Hiveの初期化エラー: $e');
  }

  // 勉強記録の同期サービス初期化
  final syncService = SyncService();
  await syncService.syncStudyRecords(); // 起動時に未送信データを送信
  syncService.startSyncTimer(); // 定期チェックを開始

  runApp(
    MultiProvider(
      providers: [
        Provider<AppService>(
          create: (_) => AppService(),
        ),
        StreamProvider<DocumentSnapshot?>(
          create: (context) =>
              context.read<AppService>().getAppSettingsStream(),
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
      title: 'Study App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

enum AuthStatus { notAuthenticated, notRegistered, authenticated }

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
    _controller = getGlobalTabController();
    _controller.jumpToTab(0);

    // Firebase Messagingの初期化と許可のリクエスト
    requestPermission();
    initFirebaseMessaging();
    getToken();
  }

  Future<AuthStatus> _checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isRegistered = await UserService().checkRegistrationStatus();
      if (!isRegistered) {
        return AuthStatus.notRegistered;
      }
      return AuthStatus.authenticated;
    }
    return AuthStatus.notAuthenticated;
  }

  // Firebase Messagingの通知許可をリクエスト
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('ユーザーは通知を許可しました');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('ユーザーは一時的な通知を許可しました');
    } else {
      print('ユーザーは通知を拒否しました');
    }
  }

  // Firebase Messagingの初期化
  void initFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('フォアグラウンドでメッセージを受信しました: ${message.messageId}');
      // フォアグラウンドでメッセージを受信した際の処理をここに記述
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('通知をクリックしてアプリを開きました: ${message.messageId}');
      // 通知をクリックしてアプリを開いた際の処理をここに記述
    });
  }

  // デバイストークンの取得
  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('デバイストークン: $token');
    // トークンをサーバーに送信する処理をここに記述
  }

  final _pages = <Widget>[
    HomeScreen(),
    RankingScreen(),
    TimePage(),
    NotificationPage(),
    MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthStatus>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ローディング状態
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          switch (snapshot.data!) {
            case AuthStatus.notAuthenticated:
              return AuthScreen();
            case AuthStatus.notRegistered:
              return AccountRegister();
            case AuthStatus.authenticated:
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
                            children: const [
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
                            children: const [
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
                          icon: const SizedBox.shrink(),
                          activeColorPrimary: Colors.transparent,
                          inactiveColorPrimary: Colors.transparent,
                          iconSize: 0.0,
                        ),
                        PersistentBottomNavBarItem(
                          icon: custom_badge.Badge(
                            position: custom_badge.BadgePosition.topEnd(
                                top: -5, end: -5),
                            badgeContent: const Text(
                              '3',
                              style: TextStyle(color: Colors.white),
                            ),
                            badgeColor: Colors.red,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
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
                            children: const [
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
                      bottom: kBottomNavigationBarHeight - 30,
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 60.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        } else {
          // エラーハンドリング
          return const Scaffold(
            body: Center(child: Text('エラーが発生しました')),
          );
        }
      },
    );
  }
}
