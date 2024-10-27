import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class GoalCalender extends StatelessWidget {
  final List<DateTime> achievedDates;

  const GoalCalender({
    Key? key,
    required this.achievedDates,
  }) : super(key: key);
  //連続達成日数を計算
  int calculateStreak(List<DateTime> dates, DateTime today) {
    if (dates.isEmpty) return 0;

    // 日付をソート
    dates.sort((a, b) => a.compareTo(b));

    int streak = 0;
    for (int i = dates.length - 1; i >= 0; i--) {
      if (dates[i].isBefore(today.subtract(Duration(days: streak)))) {
        break;
      }
      streak++;
    }

    // 今日が達成日でない場合、連続日数から1を引く
    if (!dates.contains(today)) {
      streak--;
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // 月の名前を日本語に変換するための関数
    String formatMonth(DateTime date) {
      final months = [
        '1月',
        '2月',
        '3月',
        '4月',
        '5月',
        '6月',
        '7月',
        '8月',
        '9月',
        '10月',
        '11月',
        '12月'
      ];
      return '${months[date.month - 1]} ${date.year}';
    }

    // 連続達成日数を計算する関数
    int calculateStreak(List<DateTime> dates, DateTime today) {
      if (dates.isEmpty) return 0;

      // 日付を降順でソート（新しい日付が前に来るように）
      dates.sort((a, b) => b.compareTo(a));

      int streak = 0;
      DateTime currentDate = today;

      // 今日から過去に向かって連続達成日数をカウント
      for (DateTime date in dates) {
        // 時間部分を無視して年月日のみ比較
        if (date.year == currentDate.year &&
            date.month == currentDate.month &&
            date.day == currentDate.day) {
          streak++;
          currentDate = currentDate.subtract(Duration(days: 1));
        } else if (date.isBefore(currentDate)) {
          break;
        }
      }

      return streak;
    }

    return SizedBox(
      width: double.infinity,
      height: 280, // カレンダーの高さを小さく設定
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8), // パディングを少し小さく
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.event_available,
                            color: subTheme,
                            size: 22,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            '目標達成カレンダー',
                            style: TextStyle(
                              color: subTheme,
                              fontWeight: FontWeight.bold,
                              fontSize: 20, // タイトルのフォントサイズを少し小さく
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Text(
                  //   "連続" +
                  //       calculateStreak(achievedDates, DateTime.now())
                  //           .toString() +
                  //       "日",
                  //   style: TextStyle(
                  //       color: textTeme, // Text color
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 25),
                  // ),
                ],
              ),
              Expanded(
                child: TableCalendar(
                  locale: 'ja_JP', // 曜日を日本語に
                  firstDay: firstDayOfMonth,
                  lastDay: lastDayOfMonth,
                  focusedDay: now,
                  rowHeight: 30, // セルの高さを小さく調整
                  calendarStyle: CalendarStyle(
                    cellMargin: EdgeInsets.all(2), // セルの間隔を縮小
                    todayDecoration: BoxDecoration(
                      color: subTheme,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(fontSize: 12), // セル内のテキストを小さく
                    weekendTextStyle:
                        TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 12),
                    weekendStyle: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    titleTextStyle: TextStyle(fontSize: 14), // ヘッダーのテキストサイズを調整
                    titleTextFormatter: (date, locale) =>
                        formatMonth(date), // 月名を日本語に変換
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // 目標達成した日付にアイコンを表示
                      if (achievedDates.any((d) => isSameDay(d, day))) {
                        return SizedBox(
                          width: 28,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(fontSize: 19),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 0,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text(
                          '${day.day}',
                          style: TextStyle(fontSize: 19),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
