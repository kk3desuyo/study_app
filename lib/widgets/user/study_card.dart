import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/preview_detail.dart/display_books.dart';

class StudyCard extends StatelessWidget {
  final User user;
  final int studyTime;
  final Book book;
  final String memo;
  final String id;
  final DateTime timeStamp;

  StudyCard({
    required this.user,
    required this.studyTime,
    required this.book,
    required this.memo,
    required this.id,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    print("study_card");
    print(book.title);
    return Card(
      color: backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          // 1. IntrinsicHeightでラップ
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // 2. crossAxisAlignmentをstretchに設定
            children: [
              // 左側：ユーザー情報とメモ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ユーザーのプロフィール写真と名前
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: user.profileImgUrl.isNotEmpty
                              ? NetworkImage(user.profileImgUrl)
                              : null,
                          child: user.profileImgUrl.isEmpty
                              ? Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.name.isNotEmpty ? user.name : "-----",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            if (timeStamp.day == DateTime.now().day &&
                                timeStamp.month == DateTime.now().month &&
                                timeStamp.year == DateTime.now().year) ...[
                              Text(
                                '${timeStamp.hour}:${timeStamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              Text(
                                '${timeStamp.month}月${timeStamp.day}日',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                            SizedBox(
                              height: 10,
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // 行のテキストを上揃え
                      children: [
                        BookCard(
                          book: book,
                          studyTime: studyTime,
                          isDisplayTime: false,
                          isDisplayName: false,
                        ),
                        const SizedBox(width: 8), // スペースを追加
                        Expanded(
                          // 3. Expandedでラップしてテキストがスペースを取れるようにする
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title.isEmpty ? '-----' : book.title,
                                // book.title.isNotEmpty ? book.title : '-----',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                _convertMinutesToHoursAndMinutes(studyTime),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (memo.isNotEmpty)
                      // メモセクション
                      Expanded(
                        // 4. Expandedでラップ
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            memo.isNotEmpty ? memo : 'メモ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // スペースを調整
            ],
          ),
        ),
      ),
    );
  }

  // 学習時間を "X時間Y分" の形式に変換
  String _convertMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}時間${minutes}分';
  }
}
