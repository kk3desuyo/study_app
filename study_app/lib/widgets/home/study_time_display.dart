import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_app/theme/color.dart';

class StudyTimeDisplay extends StatefulWidget {
  final int studyTime; // Change to int to represent minutes

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
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: subTheme,
                    size: 30,
                  ),
                  Text(
                    '勉強時間',
                    style: TextStyle(
                        fontSize: 24,
                        color: subTheme,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _formatStudyTime(widget.studyTime),
                style: GoogleFonts.roboto(
                  fontSize: 48, // フォントサイズを調整
                  fontWeight: FontWeight.w900, // かなり太いフォント
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
