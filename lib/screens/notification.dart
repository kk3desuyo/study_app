import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/notification/notification_item.dart';
import 'package:study_app/widgets/notification/tab_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 0;
  final UserService _userService = UserService();
  String _currentUserId = '';

  Future<void> _initializeCurrentUser() async {
    final userId = await _userService.getCurrentUserId();
    if (userId != null) {
      setState(() {
        _currentUserId = userId;
      });
    } else {
      // ユーザーがログインしていない場合の処理
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth'); // 適切なルート名に変更
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser(); // 非同期メソッドを呼び出す
  }

  // ストリームを取得するメソッド
  Stream<List<Map<String, dynamic>>> _getNotificationStream() {
    if (_selectedIndex == 0) {
      // ユーザーのフォロー・いいね関連の通知を取得
      return _userService.getAllNotifications(_currentUserId);
    } else if (_selectedIndex == 1) {
      // noticeコレクションのデータを取得
      return _userService.getNotices();
    }
    return Stream.value([]);
  }

  @override
  Widget build(BuildContext context) {
    print("currentUserId: $_currentUserId");
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
            child: _currentUserId.isEmpty
                ? Center(child: Text('ユーザー情報がありません'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getNotificationStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Center(child: Text('エラーが発生しました'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        print('通知がありません');
                        return Center(child: Text('通知はありません'));
                      } else {
                        print('通知データ: ${snapshot.data}');
                      }

                      final notifications = snapshot.data!;
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return NotificationItem(
                            title: notification['title'] ?? "お知らせ",
                            message: notification['message'] ?? "メッセージがありません",
                            dateTime:
                                notification['dateTime'] ?? DateTime.now(),
                            type: _parseNotificationType(
                                notification['type'] ?? 'other'),
                            senderName: notification['senderName'] ?? "",
                            senderId: notification['senderId'] ?? "",
                            dailyGoalId: notification['dailyGoalId'] ?? "",
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'friend_request':
        return NotificationType.friendRequest;
      case 'friend_request_accepted':
        return NotificationType.friendRequestAccepted;
      case 'community_announcement':
        return NotificationType.communityAnnouncement;
      case 'notice':
        return NotificationType.notice; // 'notice' タイプを追加
      default:
        return NotificationType.other;
    }
  }
}
