import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
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
  List<Map<String, dynamic>> friendNotifications = [];
  List<Map<String, dynamic>> communityNotifications = [];
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    fetchFriendNotifications();
    fetchCommunityNotifications();
  }

  Future<void> fetchFriendNotifications() async {
    List<Map<String, dynamic>> notifications =
        await _userService.getFriendNotifications();
    setState(() {
      friendNotifications = notifications;
    });
  }

  Future<void> fetchCommunityNotifications() async {
    List<Map<String, dynamic>> notifications =
        await _userService.getCommunityNotifications();
    setState(() {
      communityNotifications = notifications;
    });
  }

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
                  senderName: notification['senderName'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
