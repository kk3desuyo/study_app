import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '勉強時間',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              _formatStudyTime(widget.studyTime), // Convert minutes to HH:MM
              style: TextStyle(fontSize: 48),
            ),
          ],
        ),
      ),
    );
  }
}
