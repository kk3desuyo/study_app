class User {
  final String profileImgUrl;
  final String name;
  final String id;
  String oneWord;

  User({
    required this.profileImgUrl,
    required this.name,
    required this.id,
    this.oneWord = '',
  });

  // Firestoreからデータを取得してUserオブジェクトを作成するファクトリメソッド
  factory User.fromJson(Map<String, dynamic> json, String id) {
    return User(
      oneWord: json['oneWord'] ?? '',
      profileImgUrl: json['profileImgUrl'] ?? '',
      name: json['name'] ?? '',
      id: id,
    );
  }

  // UserオブジェクトをFirestoreに保存するためのJSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'oneWord': oneWord,
      'profileImgUrl': profileImgUrl,
      'name': name,
      // idはドキュメントIDとして使用されるため、ここには含めません
    };
  }
}
