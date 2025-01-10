import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final bool isStudyTimeVisible;
  final Timestamp visibilityChangeTime;

  AppSettings({
    required this.isStudyTimeVisible,
    required this.visibilityChangeTime,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isStudyTimeVisible: json['isStudyTimeVisible'] ?? false,
      visibilityChangeTime: json['visibilityChangeTime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isStudyTimeVisible': isStudyTimeVisible,
      'visibilityChangeTime': visibilityChangeTime,
    };
  }
}
