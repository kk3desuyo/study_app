import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: false,
      title: const Text(
        "Study Plus",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1)),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.group,
                color: Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1))),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings,
                color: Color.fromRGBO(mainColorR, mainColorG, mainColorB, 1)))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
