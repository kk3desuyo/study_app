import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class MyTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isChangeTime; // 修正: 'final' を追加

  const MyTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.isChangeTime = false, // 修正: デフォルト値 false を追加
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final tapPosition = details.globalPosition.dx;
        final screenWidth = MediaQuery.of(context).size.width;

        if (tapPosition < screenWidth / 2) {
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
            // 左側（記録）
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '記録',
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
            // 右側（ストップウォッチ）
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'ストップウォッチ',
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
