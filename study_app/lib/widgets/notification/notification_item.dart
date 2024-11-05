import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_app/theme/color.dart';

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
  final String? senderName;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    String timeAgo(DateTime dateTime) {
      Duration diff = DateTime.now().difference(dateTime);
      if (diff.inDays >= 1) {
        return '${diff.inDays} 日前';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours} 時間前';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes} 分前';
      } else {
        return 'たった今';
      }
    }

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

    // 相対時間を取得
    final relativeTime = timeAgo(dateTime);

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
                  if (senderName != null)
                    Text(
                      '$senderNameさんから',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        relativeTime,
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
