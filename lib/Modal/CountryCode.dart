// To parse this JSON data, do
//
//     final countryCode = countryCodeFromMap(jsonString);

import 'dart:convert';

CountryCode countryCodeFromMap(String str) => CountryCode.fromMap(json.decode(str));

String countryCodeToMap(CountryCode data) => json.encode(data.toMap());

class CountryCode {
  CountryCode({
    this.countries,
  });

  List<Country>? countries;

  factory CountryCode.fromMap(Map<String, dynamic> json) => CountryCode(
    countries: json["countries"] == null ? null : List<Country>.from(json["countries"].map((x) => Country.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "countries": countries == null ? null : List<dynamic>.from(countries!.map((x) => x.toMap())),
  };
}

class Country {
  Country({
    this.name,
    this.dialCode,
    this.code,
    this.image
  });

  String? name;
  String? dialCode;
  String? code;
  String? image;

  factory Country.fromMap(Map<String, dynamic> json) => Country(
    name: json["name"] == null ? null : json["name"],
    dialCode: json["dial_code"] == null ? null : json["dial_code"],
    code: json["code"] == null ? null : json["code"],
    image: 'assets/country/'+json["code"].toString().toLowerCase()+".png"
  );

  Map<String, dynamic> toMap() => {
    "name": name == null ? null : name,
    "dial_code": dialCode == null ? null : dialCode,
    "code": code == null ? null : code,
    "image":image
  };
}
