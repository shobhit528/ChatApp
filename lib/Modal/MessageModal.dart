import 'dart:core';

class MessageModal {
  int? senderId, receiverId;
  String? id, time, message, mediaType, image, title,user;
  List<dynamic>? users;

  MessageModal(
      {this.id,
      this.senderId,
      this.image,
      this.message,
      this.mediaType,
      this.receiverId,
      this.time,
      this.title,
      this.users,
      this.user,
      });

  Map<String, dynamic> toJson() => {
        "id": id,
        "senderId": senderId,
        "receiverId": receiverId,
        "time": time,
        "message": message,
        "mediaType": mediaType,
        "title": title,
        "image": image,
        "user": user,
        "users": users ?? [],
      };
}
