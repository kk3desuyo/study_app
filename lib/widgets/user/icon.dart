import 'package:flutter/material.dart';

class UserIcon extends StatelessWidget {
  final String profileImgUrl;
  final Function() onTap;
  double size = 42.0;
  double radius = 21.0;
  UserIcon(
      {required this.profileImgUrl,
      required this.onTap,
      this.size = 42.0,
      this.radius = 21.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: profileImgUrl.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(left: 10, bottom: 3, right: 20),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21.0),
                  image: DecorationImage(
                    image: NetworkImage(profileImgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.only(left: 4, bottom: 3, right: 3),
              child: Icon(
                Icons.account_circle,
                size: 50.0,
              ),
            ),
    );
  }
}
