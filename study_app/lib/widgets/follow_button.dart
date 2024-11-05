import 'package:flutter/material.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

class FollowButton extends StatefulWidget {
  final String followingUserId;
  final Function() onChanged;
  FollowButton({
    Key? key,
    required this.followingUserId,
    this.onChanged = _defaultOnChanged,
  }) : super(key: key);

  static void _defaultOnChanged() {}

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final status = await userService.isFollowing(
      widget.followingUserId,
    );
    setState(() {
      isFollowing = status;
    });
  }

  void _toggleFollow() async {
    await userService.updateFollowStatus(widget.followingUserId, !isFollowing);
    setState(() {
      isFollowing = !isFollowing;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // Set a fixed width to avoid resizing
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.white : subTheme,
          side: BorderSide(color: subTheme),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding:
              EdgeInsets.symmetric(vertical: 8), // Adjust padding if needed
        ),
        onPressed: _toggleFollow,
        child: Text(
          isFollowing ? 'フォロー中' : 'フォロー',
          style: TextStyle(
            color: isFollowing ? subTheme : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
