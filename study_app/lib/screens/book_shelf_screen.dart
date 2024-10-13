import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/app_bar.dart';
import 'package:study_app/widgets/user/book_shelf.dart';

class BookShelf extends StatefulWidget {
  const BookShelf({Key? key}) : super(key: key);

  @override
  State<BookShelf> createState() => _BookShelfState();
}

class _BookShelfState extends State<BookShelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: const MyAppBar(),
      body: BookShelfCard(
        books: [
          Book(
              isRecentlyUse: true,
              name: "aaa",
              id: 0,
              bookImgUrl:
                  "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTiDykdw3K7dEito1ZrEIVJkxq1P7R06m5sTim49JhDE2eyT6bfXKjazXDuqPSyGokfYaUmLCYaER-Hc-PVnt0",
              category: "理科"),
          Book(
              isRecentlyUse: true,
              name: "aaa",
              id: 1,
              bookImgUrl:
                  "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTiDykdw3K7dEito1ZrEIVJkxq1P7R06m5sTim49JhDE2eyT6bfXKjazXDuqPSyGokfYaUmLCYaER-Hc-PVnt0",
              category: "国語"),
          Book(
              isRecentlyUse: true,
              name: "aaa",
              id: 2,
              bookImgUrl:
                  "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTiDykdw3K7dEito1ZrEIVJkxq1P7R06m5sTim49JhDE2eyT6bfXKjazXDuqPSyGokfYaUmLCYaER-Hc-PVnt0",
              category: "数学"),
          Book(
              isRecentlyUse: true,
              name: "aaa",
              id: 3,
              bookImgUrl:
                  "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTiDykdw3K7dEito1ZrEIVJkxq1P7R06m5sTim49JhDE2eyT6bfXKjazXDuqPSyGokfYaUmLCYaER-Hc-PVnt0",
              category: "理科"),
        ],
      ),
    );
  }
}
