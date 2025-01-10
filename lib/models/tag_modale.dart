import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String name;
  final String id;
  final bool isAchievement;

  Tag({required this.name, required this.isAchievement, required this.id});

  factory Tag.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Tag(
      name: data['name'] ?? '',
      isAchievement: data['isAchievement'] ?? false,
      id: doc.id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isAchievement': isAchievement,
    };
  }
}
