import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class MyTabBar extends StatelessWidget {
  const MyTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      child: TabBar(
        indicator: CustomTabIndicator(),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white, // 選択されたタブのテキストカラー
        unselectedLabelColor: Colors.white70, // 未選択のタブのテキストカラー
        tabs: const [
          Tab(text: 'ホーム'),
          Tab(text: 'タイムライン'),
        ],
      ),
    );
  }
}

class CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter();
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // インジケーターの位置とサイズ
    const indicatorHeight = 2.0;
    const indicatorWidth = 20.0;

    // タブの中央を計算
    final centerX = (configuration.size!.width / 2) + offset.dx;
    final startY = configuration.size!.height - indicatorHeight;

    // インジケーターの四角形を描画
    final rect = Rect.fromCenter(
      center: Offset(centerX, startY),
      width: indicatorWidth,
      height: indicatorHeight,
    );

    // インジケーターを描画
    canvas.drawRect(rect, paint);
  }
}
