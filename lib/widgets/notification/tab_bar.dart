import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

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
          onTabSelected(1);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: BoxDecoration(
          color: subTheme,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
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
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      '通知',
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
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'お知らせ',
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
