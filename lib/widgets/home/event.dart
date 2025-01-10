import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/models/event.dart';
import 'package:study_app/widgets/user/event_modal.dart';

class EventDisplay extends StatefulWidget {
  final int daysLeft;
  final String eventName;
  final bool isEventSet;
  final Event? event; // 既存のイベントデータを渡す

  EventDisplay({
    required this.daysLeft,
    required this.eventName,
    this.isEventSet = false,
    this.event,
  });

  @override
  _EventDisplayState createState() => _EventDisplayState();
}

class _EventDisplayState extends State<EventDisplay> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2);

    return Container(
      width: cardWidth,
      height: 160,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              print("EventDisplay: イベントを追加ボタンが押されました");
              showDialog(
                context: context,
                builder: (context) {
                  return EventModal(
                    existingEvent: widget.isEventSet ? widget.event : null,
                  );
                },
              );
            },
            child: Card(
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
                child: widget.isEventSet
                    ? _buildEventContent()
                    : _buildNoEventContent(),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.outlined_flag,
                  color: subTheme,
                  size: 30,
                ),
                SizedBox(width: 5),
                Text(
                  'イベント',
                  style: TextStyle(
                      fontSize: 24,
                      color: subTheme,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent() {
    print(widget.daysLeft);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.daysLeft < 0)
          _buildNoEventContent()
        else if (widget.daysLeft == 0) ...[
          Text(
            widget.eventName,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "当日",
                style: GoogleFonts.roboto(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          )
        ] else ...[
          Text(
            widget.eventName,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "あと",
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 4),
              Text(
                widget.daysLeft.toString(),
                style: GoogleFonts.roboto(
                  fontSize: widget.daysLeft.toString().length == 4 ? 35 : 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 4),
              Text(
                "日",
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildNoEventContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: textTeme,
                size: 50,
              ),
              SizedBox(height: 2),
              Text(
                "イベントを追加",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textTeme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
