import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

LineChartData weekChart(List<double> studyTimes) {
  // メモリ幅を整数で計算する
  List<int> memoryWidths = calculateYAxisMemory(studyTimes);

  // メモリ幅の間隔を取得 (例として最初のメモリ幅を使用)
  double horizontalInterval = (memoryWidths[1] - memoryWidths[0]).toDouble();

  return LineChartData(
    // タッチ操作時の設定
    lineTouchData: LineTouchData(
      handleBuiltInTouches: true, // タッチ時のアクションの有無
      getTouchedSpotIndicator: defaultTouchedIndicators, // インジケーターの設定
      touchTooltipData: LineTouchTooltipData(
        // ツールチップの設定
        getTooltipItems: defaultLineTooltipItem, // 表示文字設定
        tooltipRoundedRadius: 2.0, // 角丸
      ),
    ),

    // 背景のグリッド線の設定
    gridData: FlGridData(
      show: true, // グリッド線の有無
      horizontalInterval: horizontalInterval, // 横線の間隔
      drawVerticalLine: false, // 縦線は描画しない
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: bottomNavInActive, // 横線の色
          strokeWidth: 1, // 横線の太さ
          dashArray: [5, 5], // 点線の設定 (破線: 5ピクセル線、5ピクセル空白)
        );
      },
    ),

    // グラフのタイトル設定
    titlesData: FlTitlesData(
      show: true, // タイトルの有無
      bottomTitles: AxisTitles(
        // 下側に表示するタイトル設定
        axisNameSize: 16.0, // タイトルの表示エリアの幅を小さくする
        sideTitles: SideTitles(
          // サイドタイトル設定
          showTitles: true, // サイドタイトルの有無
          interval: 1.0, // サイドタイトルの表示間隔
          reservedSize: 25.0, // 下部の領域を小さくする
          getTitlesWidget: bottomTitleWidgets, // サイドタイトルの表示内容
        ),
      ),
      rightTitles: AxisTitles(), // 上記と同じため割愛
      topTitles: AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, // サイドタイトルの有無
          interval: horizontalInterval, // サイドタイトルの表示間隔を設定
          reservedSize: 40.0, // サイドタイトルの表示エリアの幅
          getTitlesWidget: (value, meta) =>
              leftTitleWidgets(value, meta, studyTimes),
        ),
      ),
    ),

    // グラフの外枠線
    borderData: FlBorderData(
      show: true, // 外枠線の有無
      border: Border.all(
        // 外枠線の色
        color: Color(0xff37434d),
      ),
    ),

    // グラフのx軸y軸のの表示数
    minX: 0.0,
    maxX: 6.0,
    minY: memoryWidths.first.toDouble(),
    maxY: memoryWidths.last.toDouble(),

    // チャート線の設定
    lineBarsData: [
      LineChartBarData(
        spots: [
          // 表示する座標のリスト
          FlSpot(0.0, studyTimes[0]),
          FlSpot(1.0, studyTimes[1]),
          FlSpot(2.0, studyTimes[2]),
          FlSpot(3.0, studyTimes[3]),
          FlSpot(4.0, studyTimes[4]),
          FlSpot(5.0, studyTimes[5]),
          FlSpot(6.0, studyTimes[6]),
        ],
        color: Colors.blue,
        isCurved: false, // チャート線を曲線にするか折れ線にするか
        barWidth: 1.0, // チャート線幅
        isStrokeCapRound: false, // チャート線の開始と終了がQubicかRoundか
        dotData: FlDotData(
          show: true, // 座標のドット表示の有無
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            // ドットの詳細設定
            radius: 2.0,
            color: Colors.blue,
            strokeWidth: 2.0,
            strokeColor: Colors.blue,
          ),
        ),
        belowBarData: BarAreaData(
          // チャート線下部に色を付ける場合の設定
          show: false, // チャート線下部の表示の有無
        ),
      ),
    ],
  );
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  final DateTime now = DateTime.now(); // Get the current date and time
  const style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13.0,
  );

  // Calculate the date to be displayed based on the position (value)
  final DateTime displayedDay = now.subtract(Duration(days: 6 - value.toInt()));

  // Format the date as 'MM/dd'
  final String formattedDate = "${displayedDay.month}/${displayedDay.day}";

  Widget text = Text(formattedDate, style: style);

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta, List<double> studyTimes) {
  List<int> memorys = calculateYAxisMemory(studyTimes);
  print(studyTimes);
  print(memorys);
  const style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13.0,
  );
  String text;
  if (value.toInt() == memorys[0]) {
    text = memorys[0].toString() + "H";
  } else if (value.toInt() == memorys[1]) {
    text = memorys[1].toString() + "H";
  } else if (value.toInt() == memorys[2]) {
    text = memorys[2].toString() + "H";
  } else if (value.toInt() == memorys[3]) {
    text = memorys[3].toString() + "H";
  } else {
    return Container(); // メモリに該当しない場合は何も表示しない
  }

  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Padding(
      padding: const EdgeInsets.only(),
      child: Text(text, style: style, textAlign: TextAlign.left),
    ),
  );
}

//7日間のデータからメモリ幅を計算
List<int> calculateMemoryWidths(List<double> studyTimes) {
  if (studyTimes.isEmpty) {
    throw ArgumentError("The study time list cannot be empty");
  }

  // 勉強時間データの最小値と最大値を取得
  double minTime = studyTimes.reduce((a, b) => a < b ? a : b);
  double maxTime = studyTimes.reduce((a, b) => a > b ? a : b);

  // 最大値と最小値の範囲を取得
  double timeRange = maxTime - minTime;

  // 4つのメモリを作成するために範囲を4等分
  double memoryWidth = timeRange / 4;

  // メモリの値をリストとして返す
  List<int> memoryValues = [];
  for (int i = 0; i <= 4; i++) {
    memoryValues.add((minTime + i * memoryWidth).toInt());
  }

  return memoryValues;
}

List<int> calculateYAxisMemory(List<double> studyTimes) {
  if (studyTimes.isEmpty) {
    throw ArgumentError("The study time list cannot be empty");
  }

  // 勉強時間データの最小値と最大値を取得
  double minTime = studyTimes.reduce((a, b) => a < b ? a : b);
  double maxTime = studyTimes.reduce((a, b) => a > b ? a : b);

  // メモリを整数にするための最小値と最大値の切り上げ、切り捨て処理
  int roundedMinTime = minTime.floor();
  int roundedMaxTime = maxTime.ceil();

  // メモリの範囲を3等分して、4つのメモリを作成
  int memoryRange = roundedMaxTime - roundedMinTime;
  int memoryWidth = (memoryRange / 3).ceil(); // 3等分して4つのメモリを作成

  // メモリの値をリストとして返す
  List<int> yAxisMemories = [];
  for (int i = 0; i <= 3; i++) {
    // 4つのメモリを生成するために3つに分割
    yAxisMemories.add(roundedMinTime + i * memoryWidth);
  }

  return yAxisMemories;
}
