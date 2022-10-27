// To parse this JSON data, do
//
//     final unitList = unitListFromJson(jsonString);

import 'dart:convert';

List<UnitList> unitListFromJson(String str) =>
    List<UnitList>.from(json.decode(str).map((x) => UnitList.fromJson(x)));

String unitListToJson(List<UnitList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UnitList {
  UnitList({
    required this.id,
    required this.name,
    required this.shortName,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String shortName;
  DateTime createdAt;
  DateTime updatedAt;
  bool selected = false;

  factory UnitList.fromJson(Map<String, dynamic> json) => UnitList(
        id: json["id"],
        name: json["name"],
        shortName: json["short_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_name": shortName,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
