// logo.dart

import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;
  const Logo({Key? key, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 追加: サイズを最小限に抑える
      crossAxisAlignment: CrossAxisAlignment.center, // 中央に揃える
      children: [
        Text(
          'S',
          style: TextStyle(
            fontFamily: 'NikoMoji',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(230, 180, 34, 1),
          ),
        ),
        Text(
          'tudy ',
          style: TextStyle(
            fontFamily: 'NikoMoji',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'V',
          style: TextStyle(
            fontFamily: 'NikoMoji',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(230, 180, 34, 1),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: size * 0.3), // 下に余白を追加
          child: Icon(
            Icons.lock,
            size: size * 0.8, // アイコンのサイズを調整
          ),
        ),
        Text(
          'ult',
          style: TextStyle(
            fontFamily: 'NikoMoji',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
