import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class RankCard extends StatelessWidget {
  final int rank;

  const RankCard({
    Key? key,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 中央に配置
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: subTheme, // Button background color
                  borderRadius: BorderRadius.circular(5), // Rounded button
                ),
                child: Text(
                  '勉強時間ランク',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(), // スペーサーを追加して位置を調整
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // 下に揃える
                children: [
                  if (rank == -1)
                    Text(
                      '----',
                      style: TextStyle(
                          color: primary, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 35),
                    )
                  else
                    Text(
                      '$rank',
                      style: TextStyle(
                          color: textTeme, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 35),
                    ),
                  SizedBox(
                    width: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10), // 位置を調整
                    child: Text(
                      '位',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textTeme),
                    ),
                  ),
                ],
              ),
              Spacer(), // スペーサーを追加して位置を調整
            ],
          ),
        ),
      ),
    );
  }
}
