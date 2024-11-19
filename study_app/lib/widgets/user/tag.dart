import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class TagsWidget extends StatefulWidget {
  final List<Tag> tags;
  TagsWidget({Key? key, required this.tags}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TagsWidget();
}

class _TagsWidget extends State<TagsWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 7,
        ),
        Icon(
          Icons.local_offer,
          color: subTheme,
        ),
        SizedBox(
          width: 10,
        ),
        ...widget.tags.map((tag) => TagWidget(tag: tag)).toList(),
      ],
    );
  }
}

class TagWidget extends StatelessWidget {
  final Tag tag; // Tag型のオブジェクトを受け取る
  TagWidget({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return tag.name == ''
        ? Container()
        : Row(
            children: [
              SizedBox(
                width: 2,
              ),
              if (!tag.isAchievement)
                Icon(
                  Icons.drive_file_rename_outline,
                  color: Colors.blue,
                  size: 23,
                )
              else
                Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 21,
                ),
              SizedBox(
                width: 5,
              ),
              Text(
                tag.name.length > 9
                    ? '${tag.name.substring(0, 9)}...'
                    : tag.name,
              ),
              SizedBox(
                width: 15,
              ),
            ],
          );
  }
}

class Tag {
  final String name;
  final bool isAchievement;

  Tag({required this.name, required this.isAchievement});
}
