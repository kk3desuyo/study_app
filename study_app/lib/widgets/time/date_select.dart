import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_app/theme/color.dart'; // 日付のフォーマットに使用

class DateTimePickerWidget extends StatefulWidget {
  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // 日付選択ダイアログを表示
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // 現在の日付を初期値に設定
      firstDate: DateTime(2000), // 選択可能な最小の日付
      lastDate: DateTime(2101), // 選択可能な最大の日付
      locale: const Locale('ja'), // 日本語ロケールを設定
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 時刻選択ダイアログを表示
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime, // 現在の時刻を初期値に設定
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 日付を表示するボタン
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text(
              DateFormat.yMMMMd('ja').format(_selectedDate), // 日本語で日付をフォーマット
              style:
                  TextStyle(color: Colors.blue, fontSize: 14), // フォントサイズを14に変更
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12), // ボタン内の余白を調整
              backgroundColor: backGroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          // 時刻を表示するボタン
          ElevatedButton(
            onPressed: () => _selectTime(context),
            child: Text(
              _selectedTime.format(context), // 時刻のフォーマット
              style:
                  TextStyle(color: Colors.blue, fontSize: 14), // フォントサイズを14に変更
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12), // ボタン内の余白を調整
              backgroundColor: backGroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('日付と時刻の選択')),
      body: DateTimePickerWidget(),
    ),
  ));
}
