class UserDailyAchievement {
  final String id;
  final String achievementDate;

  UserDailyAchievement({
    required this.id,
    required this.achievementDate,
  });

  // FirestoreのドキュメントからUserDailyAchievementオブジェクトを作成する
  factory UserDailyAchievement.fromDocument(
      Map<String, dynamic> doc, String docId) {
    return UserDailyAchievement(
      id: docId,
      achievementDate: doc['achievementDate'] ?? '',
    );
  }

  // UserDailyAchievementオブジェクトをMapに変換する（Firestoreでの保存用）
  Map<String, dynamic> toMap() {
    return {
      'achievementDate': achievementDate,
    };
  }
}
