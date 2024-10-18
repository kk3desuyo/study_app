import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDisplay extends StatefulWidget {
  final int daysLeft;
  final String eventName;
  final bool isEventSet;

  EventDisplay(
      {required this.daysLeft,
      required this.eventName,
      this.isEventSet = false});

  @override
  _EventDisplayState createState() => _EventDisplayState();
}

class _EventDisplayState extends State<EventDisplay> {
  String _formatdaysLeft(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2);

    return Container(
      width: cardWidth,
      height: 160,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child:
              widget.isEventSet ? _buildEventContent() : _buildNoEventContent(),
        ),
      ),
    );
  }

  Widget _buildEventContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: [
            Icon(
              Icons.outlined_flag,
              color: subTheme,
              size: 30,
            ),
            Text(
              'イベント',
              style: TextStyle(
                  fontSize: 24, color: subTheme, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          widget.eventName,
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Column(
              children: [
                SizedBox(height: 15),
                Text(
                  "あと",
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            Text(
              widget.daysLeft.toString(),
              style: GoogleFonts.roboto(
                fontSize: 48, // フォントサイズを調整
                fontWeight: FontWeight.w900, // かなり太いフォント
              ),
            ),
            SizedBox(width: 10),
            Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "日",
                  style: GoogleFonts.roboto(
                    fontSize: 20, // フォントサイズを調整
                    fontWeight: FontWeight.w900, // かなり太いフォント
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoEventContent() {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.outlined_flag,
                color: subTheme,
                size: 30,
              ),
              Text(
                'イベント',
                style: TextStyle(
                    fontSize: 24, color: subTheme, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.add_circle_outline, color: textTeme, size: 50),
              Text(
                "----",
                style: GoogleFonts.roboto(
                    fontSize: 18, fontWeight: FontWeight.w900, color: textTeme),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
