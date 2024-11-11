// other_user_private_display_card.dart

import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/follow_button.dart';
import 'package:study_app/widgets/user/tag.dart';

class OtherUserPrivateDisplayCard extends StatelessWidget {
  final User user;
  final int followNum;
  final int followersNum;

  OtherUserPrivateDisplayCard({
    Key? key,
    required this.user,
    required this.followNum,
    required this.followersNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 15, left: 6),
          child: Column(
            children: [
              Row(
                children: [
                  if (user.profileImgUrl.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 3, right: 20),
                      child: Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          image: DecorationImage(
                            image: NetworkImage(user.profileImgUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 3, right: 3),
                      child: Icon(
                        Icons.account_circle,
                        size: 50.0,
                      ),
                    ),
                  Spacer(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("フォロー中",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(width: 4),
                        Text(
                          followNum.toString(),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("フォロワー",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(width: 4),
                        Text(followersNum.toString(),
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FollowButton(followingUserId: user.id),
                  SizedBox(width: 30)
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: 1,
                    color: Colors.black,
                  ),
                ],
              ),
              SizedBox(height: 150),
              Icon(
                Icons.lock,
                size: 50,
                color: subTheme,
              ),
              SizedBox(height: 10),
              Text(
                'このアカウントは非公開です',
                style: TextStyle(fontSize: 18, color: subTheme),
              ),
              SizedBox(height: 180)
            ],
          ),
        ),
      ),
    );
  }
}
