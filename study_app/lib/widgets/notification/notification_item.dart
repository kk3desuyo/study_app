import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_app/theme/color.dart'; // 追加

enum NotificationType {
  like,
  comment,
  friendRequest,
  announcement,
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.like:
        icon = Icons.thumb_up;
        color = Colors.blue;
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        color = Colors.green;
        break;
      case NotificationType.friendRequest:
        icon = Icons.person_add;
        color = primary;
        break;
      case NotificationType.announcement:
        icon = Icons.announcement;
        color = Colors.red;
        break;
    }

    // 日時をフォーマット
    final formattedDate = DateFormat('MM-dd HH:mm').format(dateTime);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 35),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
