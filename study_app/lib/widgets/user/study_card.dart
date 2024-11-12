import 'package:flutter/material.dart';
import 'package:study_app/models/book.dart';
import 'package:study_app/models/user.dart';

class StudyCard extends StatelessWidget {
  final User user;
  final int studyTime;
  final Book book;
  final String memo;

  StudyCard({
    required this.user,
    required this.studyTime,
    required this.book,
    required this.memo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.profileImgUrl.isNotEmpty
                      ? NetworkImage(user.profileImgUrl)
                      : null,
                  child: user.profileImgUrl.isEmpty
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
                SizedBox(width: 8),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Study Time: $studyTime minutes'),
            SizedBox(height: 8),
            Text('Book: ${book.title}'),
            SizedBox(height: 8),
            Text('Memo: $memo'),
          ],
        ),
      ),
    );
  }
}
