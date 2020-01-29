class UserModel {
  final String nickname;
  final String id;
  final String photoUrl;
  final String pushToken;
  final String aboutMe;

  UserModel({
    this.nickname,
    this.id,
    this.photoUrl,
    this.pushToken,
    this.aboutMe,
  });

  UserModel copyWith({
    String nickname,
    String id,
    String photoUrl,
    String pushToken,
    String aboutMe,
  }) =>
      UserModel(
        nickname: nickname ?? this.nickname,
        id: id ?? this.id,
        photoUrl: photoUrl ?? this.photoUrl,
        pushToken: pushToken ?? this.pushToken,
        aboutMe: aboutMe ?? this.aboutMe,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        nickname: json["nickname"] == null ? null : json["nickname"],
        id: json["id"] == null ? null : json["id"],
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
        pushToken: json["pushToken"] == null ? null : json["pushToken"],
        aboutMe: json["aboutMe"] == null ? null : json["aboutMe"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "id": id == null ? null : id,
        "photoUrl": photoUrl == null ? null : photoUrl,
        "pushToken": pushToken == null ? null : pushToken,
        "aboutMe": aboutMe == null ? null : aboutMe,
      };
}
