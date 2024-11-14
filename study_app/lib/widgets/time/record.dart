import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/study_session.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/time/book_preview.dart';
import 'package:study_app/widgets/time/date_select.dart';
import '../preview_detail.dart/display_books.dart';
import 'package:study_app/services/study_session.dart';

class Record extends StatefulWidget {
  final int studyTime;
  final Map<int, Book> bookInfos;
  final Function(bool) changeTime;
  final bool isTimeChange;

  const Record({
    Key? key,
    required this.studyTime,
    required this.bookInfos,
    required this.changeTime,
    required this.isTimeChange,
  }) : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String isSelectedCategory = '全てのカテゴリー';
  DateTime selectedDate = DateTime.now();
  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedBook = -1;
  String memo = '';
  final StudySessionService studySessionService = StudySessionService();
  bool _isSaving = false;
  bool _isSuccess = false;

  void _openBookSelectionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookSelectionPage(
          bookInfos: widget.bookInfos,
          onBookSelected: (int selectedBookId) {
            setState(() {
              selectedBook = selectedBookId;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize selectedHour and selectedMinute with studyTime
    selectedHour = widget.studyTime ~/ 60;
    selectedMinute = widget.studyTime % 60;
    print("再描画");
    print(selectedHour);
    print(selectedMinute);
  }

  String formatTimeInJapanese(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours時間$minutes分";
  }

  void _saveStudySession() async {
    if (selectedBook == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('教材が選択されていません'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (selectedHour * 60 + selectedMinute == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('勉強時間が0分です'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _isSuccess = false;
    });

    StudySession newSession = StudySession(
      id: '',
      bookId: widget.bookInfos[selectedBook]!.id,
      isTimeChange: widget.isTimeChange,
      memo: memo,
      studyTime: selectedHour * 60 + selectedMinute,
      timeStamp: selectedDate,
      userId: UserService().getCurrentUserId() ?? 'unknown_user',
    );

    try {
      await studySessionService.addStudySession(newSession);
      print('StudySession saved successfully');

      setState(() {
        _isSaving = false;
        _isSuccess = true;
      });

      // 成功時にフィールドをリセット
      _resetFields();

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isSuccess = false;
        });
      });
    } catch (e) {
      print('Error saving StudySession: $e');
      setState(() {
        _isSaving = false;
      });
      // エラー時にポップアップを表示
      _showErrorDialog();
    }
  }

  void _resetFields() {
    setState(() {
      selectedDate = DateTime.now();
      selectedHour = 0;
      selectedMinute = 0;
      selectedBook = -1;
      memo = '';
      widget.changeTime(false);
    });
  }

  // エラー発生時のダイアログを表示するメソッドを追加
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラーが発生しました'),
          content: Text('データの送信に失敗しました。再度お試しください。'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _showConfirmTimeChange() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 300,
            height: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: subTheme),
                const SizedBox(height: 10),
                const Text(
                  '時間を変更すると、記録した勉強時間はランキングには反映されません。時間の変更を行いますか?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    widget.changeTime(true);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showTimePickerModal() async {
    if (!widget.isTimeChange) {
      await _showConfirmTimeChange();
    }

    if (widget.isTimeChange) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("完了"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPicker(
                      value: selectedHour,
                      max: 23,
                      onChanged: (index) {
                        setState(() {
                          selectedHour = index;
                        });
                      },
                    ),
                    const Text(":",
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold)),
                    _buildPicker(
                      value: selectedMinute,
                      max: 59,
                      onChanged: (index) {
                        setState(() {
                          selectedMinute = index;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildPicker(
      {required int value,
      required int max,
      required Function(int) onChanged}) {
    return Container(
      height: 150,
      width: 100,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: value),
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        children: _buildNumberList(max),
      ),
    );
  }

  List<Widget> _buildNumberList(int maxNumber) {
    return List<Widget>.generate(maxNumber + 1, (index) {
      return Center(child: Text(index.toString().padLeft(2, '0')));
    });
  }

  Widget _buildAddBookCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 78,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving || _isSuccess) {
      // アニメーションのみを表示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Lottie.asset(
              _isSaving
                  ? 'assets/animation/loading.json'
                  : 'assets/animation/success.json',
              width: 200,
              height: 200,
            ),
          ),
        ),
      );
    } else {
      // メインコンテンツを表示
      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (widget.isTimeChange)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "今回の勉強時間はランキングに反映されません。",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  const SizedBox(height: 15),
                  // 日付選択
                  Row(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 25),
                            decoration: BoxDecoration(
                              color: subTheme,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              '日付',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "KiwiMaru-Regular"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      DateTimePickerWidget(
                        initialDate: selectedDate,
                        initialTime: TimeOfDay(
                            hour: selectedHour, minute: selectedMinute),
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        onTimeChanged: (time) {
                          setState(() {
                            selectedHour = time.hour;
                            selectedMinute = time.minute;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // 勉強時間
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            decoration: BoxDecoration(
                              color: subTheme,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              '勉強時間',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "KiwiMaru-Regular"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Text(
                        formatTimeInJapanese(
                            selectedHour * 60 + selectedMinute),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _showTimePickerModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: subTheme),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "時間変更",
                          style: TextStyle(color: subTheme),
                        ),
                      ),
                    ],
                  ),
                  // 教材選択
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 25),
                        decoration: BoxDecoration(
                          color: subTheme,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          '教材',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: "KiwiMaru-Regular"),
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: _openBookSelectionPage,
                        child: selectedBook == -1
                            ? _buildAddBookCard()
                            : widget.bookInfos.containsKey(selectedBook)
                                ? BookCard(
                                    book: widget.bookInfos[selectedBook]!,
                                    studyTime: 300,
                                    isDisplayTime: false,
                                    isTapDisabled: true,
                                  )
                                : _buildAddBookCard(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // メモ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 25),
                        decoration: BoxDecoration(
                          color: subTheme,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'メモ',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: "KiwiMaru-Regular"),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: TextField(
                        maxLines: 2,
                        minLines: 2,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'めも',
                          hintStyle: TextStyle(
                            fontSize: 11.0,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 15.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            memo = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // 記録ボタン
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveStudySession,
                    child: const Text("記録する"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 35),
                      backgroundColor: Colors.white,
                      foregroundColor: subTheme,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: subTheme),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
