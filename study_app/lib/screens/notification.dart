import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/notification/notification_item.dart';
import 'package:study_app/widgets/notification/tab_bar.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> friendNotifications = [
    {
      'title': 'いいね！',
      'message': 'あなたの投稿にいいねがありました。',
      'dateTime': DateTime.now().subtract(Duration(days: 2)),
      'type': NotificationType.like,
    },
    {
      'title': 'コメント',
      'message': 'あなたの投稿にコメントがありました。',
      'dateTime': DateTime.now().subtract(Duration(days: 1)),
      'type': NotificationType.comment,
    },
    {
      'title': 'フレンドリクエスト',
      'message': '新しいフレンドリクエストがあります。',
      'dateTime': DateTime.now().subtract(Duration(hours: 5)),
      'type': NotificationType.friendRequest,
    },
  ];

  final List<Map<String, dynamic>> communityNotifications = [
    {
      'title': 'アップデートのお知らせ',
      'message': 'アプリの新しいバージョンが利用可能です。',
      'dateTime': DateTime.now().subtract(Duration(hours: 1)),
      'type': NotificationType.announcement,
    },
    {
      'title': 'イベントのお知らせ',
      'message': '新しいイベントが追加されました。',
      'dateTime': DateTime.now().subtract(Duration(days: 3)),
      'type': NotificationType.announcement,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: MyAppBar(),
      body: Column(
        children: [
          MyTabBar(
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedIndex == 0
                  ? friendNotifications.length
                  : communityNotifications.length,
              itemBuilder: (context, index) {
                final notification = _selectedIndex == 0
                    ? friendNotifications[index]
                    : communityNotifications[index];
                return NotificationItem(
                  title: notification['title'],
                  message: notification['message'],
                  dateTime: notification['dateTime'],
                  type: notification['type'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
