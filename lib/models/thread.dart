import 'package:chatdemo/models/userModel.dart';

class ThreadModel {
  String name;
  String id;
  String photoUrl;
  String lastMessage;
  String lastMessageTime;
  List<UserModel> users;

  ThreadModel({
    this.name,
    this.id,
    this.photoUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.users,
  });

  ThreadModel copyWith({
    String name,
    String id,
    String photoUrl,
    String lastMessage,
    String lastMessageTime,
    List<UserModel> users,
  }) =>
      ThreadModel(
        name: name ?? this.name,
        id: id ?? this.id,
        photoUrl: photoUrl ?? this.photoUrl,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        users: users ?? this.users,
      );

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"],
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
        lastMessage: json["lastMessage"] == null ? '' : json["lastMessage"],
        lastMessageTime:
            json["lastMessageTime"] == null ? null : json["lastMessageTime"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "id": id == null ? null : id,
        "photoUrl": photoUrl == null ? null : photoUrl,
        "lastMessage": lastMessage == null ? null : lastMessage,
        "lastMessageTime": lastMessageTime == null ? null : lastMessageTime,
      };

  @override
  String toString() {
    print('name: $name - id: $id - photo: $photoUrl - lastMsg: $lastMessage');
    return super.toString();
  }
}
