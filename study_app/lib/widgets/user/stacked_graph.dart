import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudyTimeBarChart extends StatefulWidget {
  final List<Map<String, double>> studyTimes; // Study time per day per subject
  final List<Map<String, dynamic>> subjects; // 科目名と色のリスト

  StudyTimeBarChart({required this.studyTimes, required this.subjects});

  @override
  State<StatefulWidget> createState() => _StudyTimeBarChartState();
}

class _StudyTimeBarChartState extends State<StudyTimeBarChart> {
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
                final barsSpace = 0.2 *
                    constraints.maxWidth /
                    400; // Adjusted for more even spacing
                final barsWidth =
                    (constraints.maxWidth / (widget.studyTimes.length * 2))
                        .clamp(8.0, 40.0); // Adjust the width of the bars

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
                          interval: 1,
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
                      horizontalInterval: 1,
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

  List<BarChartGroupData> _getBarGroups(double barsWidth, double barsSpace) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < widget.studyTimes.length; i++) {
      List<BarChartRodStackItem> stackItems = [];
      double previousY = 0;

      widget.studyTimes[i].forEach((subject, time) {
        // 科目名と色を取得する
        final subjectData = widget.subjects.firstWhere(
          (element) => element['name'] == subject,
          orElse: () => {'color': Colors.grey},
        );

        stackItems.add(
          BarChartRodStackItem(
              previousY, previousY + time, subjectData['color']),
        );
        previousY += time;
      });

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: barsSpace,
          barRods: [
            BarChartRodData(
              toY: previousY, // Total height for the day
              rodStackItems: stackItems, // Stack subjects' study times
              borderRadius: BorderRadius.circular(0),
              width: barsWidth,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd');
    final date = now.subtract(Duration(days: 6 - value.toInt()));
    final formattedDate = formatter.format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formattedDate, style: const TextStyle(fontSize: 10)),
    );
  }
}

// 科目とその色の表示
class SubjectLegend extends StatelessWidget {
  // subjectsリストを引数として受け取る
  final List<Map<String, dynamic>> subjects;

  SubjectLegend({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // アイテム間の水平スペース
      runSpacing: 8.0, // アイテム間の垂直スペース（次の行との間隔）
      children: subjects.map((subject) {
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
                  color: subject['color'],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3), // アイコンとテキストの間の隙間
              // 科目名を表示
              Text(
                subject['name'].length <= 4
                    ? subject['name']
                    : '${subject['name'].substring(0, 4)}…',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
