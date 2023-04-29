class ContactModal {
  ContactModal({this.name, this.number, this.isRegistered});

  String? name, number;
  bool? isRegistered;

  factory ContactModal.fromMap(Map<String, dynamic> json) => ContactModal(
        name: json["name"] == null ? null : json["name"],
        number: json["number"] == null ? null : json["number"],
        isRegistered:
            json["isRegistered"] == null ? false : json["isRegistered"],
      );

  Map<String, dynamic> toMap() => {
        "name": name == null ? null : name,
        "number": number == null ? null : number,
        "isRegistered": isRegistered == null ? false : isRegistered
      };
}
