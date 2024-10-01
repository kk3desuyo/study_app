import 'package:flutter/material.dart';
import 'package:study_app/screens/home.dart';
import 'package:study_app/theme/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  static const _screens = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20), // 下に20px移動（この数値で位置を調整できます）
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1),
            borderRadius: BorderRadius.circular(35), // 角丸
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // 影の色
                spreadRadius: 5, // 影の広がり
                blurRadius: 7, // ぼかし
                offset: const Offset(0, 3), // 影の位置
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.access_time, // 時計アイコン
              size: 60.0,
              color: Colors.white, // アイコンの色
            ),
            onPressed: () {
              //時間計測画面に遷移
              _onItemTapped(2);
            },
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.stacked_bar_chart,
              ),
              label: 'レポート'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'お知らせ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
        ],
        selectedItemColor:
            Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
