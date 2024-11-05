import 'package:flutter/material.dart';
import 'package:study_app/screens/other_user_display.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/follow_button.dart';

class FollowedAndFollowing extends StatefulWidget {
  final String userId;
  final String userName;
  final int initalSelectedIndex;
  final Function() onChanged;

  FollowedAndFollowing(
      {Key? key,
      required this.userId,
      required this.userName,
      required this.initalSelectedIndex,
      required this.onChanged})
      : super(key: key);

  @override
  _FollowedAndFollowingState createState() => _FollowedAndFollowingState();
}

class _FollowedAndFollowingState extends State<FollowedAndFollowing>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  List<User> followingUsers = [];
  List<User> follow = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = widget.initalSelectedIndex;
    _fetchData();
  }

  //フォローボタン押した時の処理
  void _onChanged() {
    _fetchData();
    widget.onChanged();
  }

  Future<void> _fetchData() async {
    try {
      final following = await _userService.getFollowingUsers(widget.userId);
      final follow = await _userService.getFollowUsers(widget.userId);
      setState(() {
        followingUsers = following;
        this.follow = follow;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching follow data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 背景を白色に設定
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primary),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0), // タブバーの高さを小さく設定
          child: TabBar(
            controller: _tabController,
            indicatorColor: subTheme, // タブ選択時の下線の色を subTheme に設定
            labelColor: subTheme, // 選択中のタブのテキスト色
            unselectedLabelColor: Colors.grey, // 未選択のタブのテキスト色
            tabs: [
              Tab(text: "フォロー中"),
              Tab(text: "フォロワー"),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(follow),
                _buildUserList(followingUsers),
              ],
            ),
    );
  }

  Widget _buildUserList(List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          _tabController.index == 0 ? "フォロー中のユーザーがいません。" : "フォロワーがいません。",
        ),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserDisplay(user: user),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: user.profileImgUrl.isNotEmpty
                  ? NetworkImage(user.profileImgUrl)
                  : null,
              backgroundColor: subTheme,
              child: user.profileImgUrl.isEmpty ? Text(user.name[0]) : null,
            ),
          ),
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserDisplay(user: user),
                ),
              );
            },
            child: Text(
              user.name.length > 8
                  ? '${user.name.substring(0, 8)}...'
                  : user.name,
            ),
          ),
          trailing: FollowButton(
            followingUserId: user.id,
            onChanged: _onChanged,
          ),
        );
      },
    );
  }
}
