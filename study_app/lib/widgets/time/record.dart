import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/time/book_preview.dart';

import 'package:study_app/widgets/time/date_select.dart';
import 'package:study_app/widgets/user/book_shelf.dart';
import '../preview_detail.dart/display_books.dart';

class Record extends StatefulWidget {
  final int studyTime;
  final Map<int, Book> bookInfos;
  final VoidCallback onChangedTime;
  final bool isTimeChange;

  const Record(
      {Key? key,
      required this.studyTime,
      required this.bookInfos,
      required this.onChangedTime,
      required this.isTimeChange})
      : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String isSelectedCategory = '全てのカテゴリー';

  //カテゴリー変更時
  void _onChangedCategory(String? value) {
    print(value);
    if (value != null) {
      setState(() {
        isSelectedCategory = value;
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final categories =
        widget.bookInfos.values.map((book) => book.category).toSet().toList();
    categories.insert(0, '全てのカテゴリー');
    return categories
        .map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ))
        .toList();
  }

  List<Book> _filteredBooks() {
    if (isSelectedCategory == '全てのカテゴリー') {
      return widget.bookInfos.values.toList();
    } else {
      return widget.bookInfos.values
          .where((book) => book.category == isSelectedCategory)
          .toList();
    }
  }

  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedBook = -1; // 選択された教材のID

  @override
  void initState() {
    super.initState();
    selectedHour = widget.studyTime ~/ 60;
    selectedMinute = widget.studyTime % 60;
  }

  String formatTimeInJapanese(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours時間$minutes分";
  }

  List<Widget> _buildNumberList(int maxNumber) {
    return List<Widget>.generate(maxNumber + 1, (index) {
      return Center(child: Text(index.toString().padLeft(2, '0')));
    });
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
                Icon(Icons.warning, color: Colors.orange),
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
                  onPressed: widget.onChangedTime,
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
            Navigator.pop(
                context); // Go back to the previous page after selecting a book
          },
        ),
      ),
    );
  }

  void _showBookSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: backGroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildModalHeader(),
              _buildBookGrid(),
            ],
          ),
        );
      },
    );
  }

// モーダル内のヘッダーウィジェット
  Widget _buildModalHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              const SizedBox(width: 50),
              Expanded(
                child: Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.close, color: primary),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: isSelectedCategory, // 現在の選択を反映
                items: _buildDropdownItems(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      isSelectedCategory = value;
                      print('カテゴリーが変更されました: $isSelectedCategory');
                    });
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10, // Adjusting spacing between items
          mainAxisSpacing: 1, // Adjusting vertical spacing between items
          childAspectRatio: 0.7, // Adjust the aspect ratio for your grid items
        ),
        itemCount: widget.bookInfos.length < 7
            ? widget.bookInfos.length + 1
            : 8, // 最大8個のBookCardを表示
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: _buildAddBookCard());
          } else {
            final bookKey = widget.bookInfos.keys.elementAt(index - 1);
            final book = widget.bookInfos[bookKey]!;
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedBook = bookKey;
                });
              },
              child: BookCard(
                bookImgUrl: book.bookImgUrl,
                name: book.name,
                studyTime: 300,
                isDisplayTime: false,
              ),
            );
          }
        },
      ),
    );
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
    print("再描画がトリガーされました");
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
      child: Column(
        children: [
          if (widget.isTimeChange)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(width: 5),
                Text(
                  "今回の勉強時間はランキングに反映されません。",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Column(
                children: [
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.orange,
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
              DateTimePickerWidget(),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
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
                formatTimeInJapanese(selectedHour * 60 + selectedMinute),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _showTimePickerModal,
                child: const Text("時間変更"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 1, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.orange,
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
                            name: widget.bookInfos[selectedBook]!.name,
                            bookImgUrl:
                                widget.bookInfos[selectedBook]!.bookImgUrl,
                            studyTime: 300,
                            isDisplayTime: false,
                          )
                        : _buildAddBookCard(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.orange,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const TextField(
                  maxLines: 2,
                  minLines: 2,
                  style: TextStyle(
                    fontSize: 11.0,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'めも',
                    hintStyle: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          ElevatedButton(
            onPressed: () => {},
            child: const Text("記録する"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 35),
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
