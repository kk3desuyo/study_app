import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:study_app/theme/color.dart'; // 日付のフォーマットに使用

class DateTimePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  DateTimePickerWidget({
    required this.initialDate,
    required this.initialTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  // ドラムロール形式の日付ピッカーを表示
  Future<void> _showDatePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('完了'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2101),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                    widget.onDateChanged(_selectedDate);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ドラムロール形式の時刻ピッカーを表示
  Future<void> _showTimePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('完了'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      _selectedTime = TimeOfDay.fromDateTime(newTime);
                    });
                    widget.onTimeChanged(_selectedTime);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
            onPressed: () => _showDatePicker(context),
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
            onPressed: () => _showTimePicker(context),
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
