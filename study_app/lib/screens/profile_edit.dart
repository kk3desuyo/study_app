import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/notification/notification_item.dart';
import 'package:study_app/widgets/notification/tab_bar.dart';
import 'package:study_app/widgets/user/profile_edit_card.dart';
import 'package:study_app/widgets/user/tag.dart';

class ProfileEditPage extends StatefulWidget {
  final List<Tag> tags;
  final Function() onChanged;
  final User user;
  ProfileEditPage(
      {required this.tags, required this.onChanged, required this.user});

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: Text(
          "プロフィール編集",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primary),
        ),
      ),
      body: ProfileForm(
        onChanged: widget.onChanged,
        name: widget.user.name,
        oneWord: widget.user.oneWord,
        tags: widget.tags,
        profileImgUrl: widget.user.profileImgUrl,
      ),
    );
  }
}
