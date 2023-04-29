class BackupModal {
  final List<dynamic>? chatList;
  final List<dynamic>? messagesList;

  BackupModal({this.chatList, this.messagesList});

  BackupModal.fromJson(Map<String, dynamic> json)
      : chatList = json["chatList"],
        messagesList = json["messageList"];

  Map<String, dynamic> toJson() =>
      {"chatList": chatList, "messageList": messagesList};
}
