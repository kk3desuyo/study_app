import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/theme/color.dart';

class StudyTimeDisplay extends StatefulWidget {
  final int studyTime;

  StudyTimeDisplay({required this.studyTime});

  @override
  _StudyTimeDisplayState createState() => _StudyTimeDisplayState();
}

class _StudyTimeDisplayState extends State<StudyTimeDisplay> {
  String _formatStudyTime(int minutes) {
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
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
              child: Center(
                child: Text(
                  _formatStudyTime(widget.studyTime),
                  style: GoogleFonts.roboto(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
                  Icons.schedule,
                  color: subTheme,
                  size: 30,
                ),
                SizedBox(width: 5),
                Text(
                  '勉強時間',
                  style: TextStyle(
                      fontSize: 24,
                      color: subTheme,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
