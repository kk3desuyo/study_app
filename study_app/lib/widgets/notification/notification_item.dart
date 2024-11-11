import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';

import 'package:study_app/screens/preview_detail.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/screens/other_user_display.dart'; // OtherUserDisplay をインポート
import 'package:intl/intl.dart'; // 日付フォーマット用

enum NotificationType {
  like,
  comment,
  friendRequest,
  friendRequestAccepted,
  communityAnnouncement,
  followed, // 新規追加
  notice, // 新規追加
  other, // デフォルト
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final String? senderName;
  final String? senderId;
  final String? dailyGoalId;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.dailyGoalId,
    this.senderName,
    this.senderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // デバッグ用のログ出力
    print(
        'Notification Item - title: $title, message: $message, senderName: $senderName');

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

    // 通知タイプに応じたアイコンと色の設定
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
      case NotificationType.friendRequestAccepted:
        icon = Icons.person;
        color = Colors.orange;
        break;
      case NotificationType.communityAnnouncement:
        icon = Icons.announcement;
        color = Colors.red;
        break;
      case NotificationType.followed:
        icon = Icons.person_add_alt_1;
        color = Colors.purple;
        break;
      case NotificationType.notice:
        icon = Icons.info_outline; // notice専用のアイコン
        color = Colors.teal; // notice専用の色
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    // 相対時間を取得
    final relativeTime = timeAgo(dateTime);

    // 通知タイプがnoticeの場合とそれ以外でレイアウトを分岐
    if (type == NotificationType.notice) {
      return Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, // notice専用のタイトル
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message, // notice専用のメッセージ
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        relativeTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 通知タイプがnotice以外の場合のレイアウト
      return GestureDetector(
        onTap: () async {
          // 各タイプに応じて画面遷移
          if (type == NotificationType.friendRequest ||
              type == NotificationType.friendRequestAccepted ||
              type == NotificationType.followed) {
            // senderId を使ってユーザー情報を取得
            if (senderId != null && senderId!.isNotEmpty) {
              try {
                User? senderUser = await UserService().getUser(senderId!);
                if (senderUser != null) {
                  // OtherUserDisplay 画面に遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherUserDisplay(user: senderUser),
                    ),
                  );
                } else {
                  // ユーザーが見つからない場合の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not found')),
                  );
                }
              } catch (error) {
                // ユーザー取得エラーの処理
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching user')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sender ID is null or empty')),
              );
            }
          } else if (type == NotificationType.like) {
            // 'like' タイプの通知の場合
            if (senderId != null && senderId!.isNotEmpty) {
              try {
                String? currentUserId = await UserService().getCurrentUserId();
                if (currentUserId != null) {
                  User? currentUser =
                      await UserService().getUser(currentUserId);
                  if (currentUser != null &&
                      dailyGoalId != null &&
                      dailyGoalId!.isNotEmpty) {
                    // PreviewDetailScreen 画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewDetailScreen(
                            user: currentUser, dailyGoalId: dailyGoalId!),
                      ),
                    );
                  } else {
                    // ユーザーが見つからない、または dailyGoalId が不正の場合の処理
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid user or DailyGoal ID')),
                    );
                  }
                } else {
                  // ユーザーが見つからない場合の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Current user not found')),
                  );
                }
              } catch (error) {
                // ユーザー取得エラーの処理
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching user')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sender ID is null or empty')),
              );
            }
          }
        },
        child: Card(
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
                      if (senderName != null &&
                          (type == NotificationType.friendRequest ||
                              type == NotificationType.friendRequestAccepted ||
                              type == NotificationType.followed))
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
        ),
      );
    }
  }
}
