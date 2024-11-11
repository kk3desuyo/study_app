class User {
  final String profileImgUrl;
  final String name;
  final String id;
  String oneWord;
  final bool isPublic;

  User({
    required this.profileImgUrl,
    required this.name,
    required this.id,
    this.oneWord = '',
    this.isPublic = false,
  });

  // Firestoreからデータを取得してUserオブジェクトを作成するファクトリメソッド
  factory User.fromJson(Map<String, dynamic> json, String id) {
    return User(
      isPublic: json['isPublic'] ?? false,
      oneWord: json['oneWord'] ?? '',
      profileImgUrl: json['profileImgUrl'] ?? '',
      name: json['name'] ?? '',
      id: id,
    );
  }

  // UserオブジェクトをFirestoreに保存するためのJSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'isPublic': isPublic,
      'oneWord': oneWord,
      'profileImgUrl': profileImgUrl,
      'name': name,
      // idはドキュメントIDとして使用されるため、ここには含めません
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, profileImgUrl: $profileImgUrl, oneWord: $oneWord, isPublic: $isPublic}';
  }
}
