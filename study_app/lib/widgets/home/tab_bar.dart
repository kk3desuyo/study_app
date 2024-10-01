import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MyTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final tapPosition = details.globalPosition.dx;
        final screenWidth = MediaQuery.of(context).size.width;

        if (tapPosition < screenWidth / 2) {
          // 左側（友達タブ）がタップされた
          onTabSelected(0);
        } else {
          // 右側（コミュニティータブ）がタップされた
          onTabSelected(1);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 10),
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
                        color:
                            selectedIndex == 0 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedIndex == 0)
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
                        color:
                            selectedIndex == 1 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedIndex == 1)
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
    );
  }
}
