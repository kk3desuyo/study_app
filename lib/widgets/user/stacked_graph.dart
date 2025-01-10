import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // 切り上げに必要

class StudyTimeBarChart extends StatefulWidget {
  final List<Map<String, double>> studyTimes; // 各日の科目ごとの学習時間
  final List<Map<String, dynamic>> subjects; // 科目名と色のリスト

  StudyTimeBarChart({required this.studyTimes, required this.subjects});

  @override
  State<StatefulWidget> createState() => _StudyTimeBarChartState();
}

class _StudyTimeBarChartState extends State<StudyTimeBarChart> {
  late double yAxisMax; // Y軸の最大値
  late double interval; // Y軸のメモリ間隔

  @override
  void initState() {
    super.initState();
    _calculateYAxisValues();
  }

  @override
  void didUpdateWidget(covariant StudyTimeBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studyTimes != widget.studyTimes) {
      _calculateYAxisValues();
    }
  }

  // Y軸の最大値とメモリ間隔を計算する関数
  void _calculateYAxisValues() {
    double maxTime = 0;
    for (var dayData in widget.studyTimes) {
      double dayTotal = dayData.values.fold(0, (sum, time) => sum + time);
      if (dayTotal > maxTime) {
        maxTime = dayTotal;
      }
    }
    // 最大値を5の倍数に切り上げる。もし最大値が0なら、デフォルトで5に設定
    yAxisMax = max((maxTime / 5).ceil() * 5.0, 5.0);
    interval = yAxisMax / 5;
    setState(() {}); // 状態を更新
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // グラフ部分
        AspectRatio(
          aspectRatio: 1.66,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barsSpace =
                    0.2 * constraints.maxWidth / 400; // スペースを均等に調整
                final barsWidth =
                    (constraints.maxWidth / (widget.studyTimes.length * 2))
                        .clamp(8.0, 40.0); // 棒の幅を調整

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: _bottomTitles,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: interval, // メモリ間隔を設定
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: interval, // メモリ間隔を設定
                      checkToShowHorizontalLine: (value) => true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    groupsSpace: barsSpace,
                    barGroups: _getBarGroups(barsWidth, barsSpace),
                    maxY: yAxisMax, // 計算した最大値を設定
                  ),
                );
              },
            ),
          ),
        ),
        // 科目名と色の凡例を表示する部分
        Padding(
          padding: const EdgeInsets.only(top: 16), // グラフとの間にスペースを追加
          child: SubjectLegend(subjects: widget.subjects), // SubjectLegendを表示
        ),
      ],
    );
  }

  // 棒グラフデータを生成する関数
  List<BarChartGroupData> _getBarGroups(double barsWidth, double barsSpace) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < widget.studyTimes.length; i++) {
      List<BarChartRodStackItem> stackItems = [];
      double previousY = 0;

      widget.studyTimes[i].forEach((subject, time) {
        Color color = Colors.grey; // デフォルト色を設定

        for (var element in widget.subjects) {
          if (element.keys.first == subject) {
            color = element.values.first as Color? ?? Colors.grey;
            break;
          }
        }

        stackItems.add(
          BarChartRodStackItem(previousY, previousY + time, color),
        );
        previousY += time;
      });

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: barsSpace,
          barRods: [
            BarChartRodData(
              toY: previousY, // その日の合計高さ
              rodStackItems: stackItems, // 科目ごとの学習時間を積み上げ
              borderRadius: BorderRadius.zero,
              width: barsWidth,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  // 下部の日付ラベルを生成する関数
  Widget _bottomTitles(double value, TitleMeta meta) {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd');

    // valueは0からstudyTimes.length - 1までの値
    int dayOffset = widget.studyTimes.length - 1 - value.toInt();
    final date = now.subtract(Duration(days: dayOffset));
    final formattedDate = formatter.format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formattedDate, style: const TextStyle(fontSize: 10)),
    );
  }
}

// 科目名と色の凡例を表示するウィジェット
class SubjectLegend extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  SubjectLegend({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // アイテム間の水平スペース
      runSpacing: 8.0, // アイテム間の垂直スペース（次の行との間隔）
      children: subjects.map((subject) {
        if (subject.isEmpty) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 行のサイズを最小限に
            children: [
              // 円を描画
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: subject.values.first as Color? ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3), // アイコンとテキストの間の隙間
              // 科目名を表示
              Text(
                subject.keys.first != null &&
                        (subject.keys.first as String).length <= 6
                    ? subject.keys.first
                    : '${(subject.keys.first as String?)?.substring(0, 6) ?? 'Unknown'}…',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
