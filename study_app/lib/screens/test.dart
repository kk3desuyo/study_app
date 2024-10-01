import 'package:flutter/material.dart';

class CustomTabBarWithState extends StatefulWidget {
  @override
  _CustomTabBarWithStateState createState() => _CustomTabBarWithStateState();
}

class _CustomTabBarWithStateState extends State<CustomTabBarWithState> {
  int _selectedIndex = 0; // 現在の選択されているタブのインデックス

  void _onTapDown(TapDownDetails details, BuildContext context) {
    final tapPosition = details.globalPosition.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    if (tapPosition < screenWidth / 2) {
      // 左側（友達タブ）がタップされた
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      // 右側（コミュニティータブ）がタップされた
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTapDown: (TapDownDetails details) => _onTapDown(details, context),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 左側（友達）
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            '友達',
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedIndex == 0)
                          Container(
                            height: 4,
                            width: 40,
                            color: Colors.white, // 選択中のタブに白いバーを表示
                          ),
                      ],
                    ),
                  ),
                  // 右側（コミュニティ）
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'コミュニティー',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedIndex == 1)
                          Container(
                            height: 4,
                            width: 40,
                            color: Colors.white, // 選択中のタブに白いバーを表示
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 各タブに対応するコンテンツを表示
          Expanded(
            child: _selectedIndex == 0
                ? Center(child: Text('友達のコンテンツ'))
                : Center(child: Text('コミュニティーのコンテンツ')),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: CustomTabBarWithState(),
    ));
