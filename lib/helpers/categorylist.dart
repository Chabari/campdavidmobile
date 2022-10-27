// To parse this JSON data, do
//
//     final categoryList = categoryListFromJson(jsonString);

import 'dart:convert';

import 'package:campdavid/helpers/productlists.dart';

List<CategoryList> categoryListFromJson(String str) => List<CategoryList>.from(
    json.decode(str).map((x) => CategoryList.fromJson(x)));

String categoryListToJson(List<CategoryList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryList {
  CategoryList({
    required this.id,
    required this.name,
    required this.shortName,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String shortName;
  String photo;
  DateTime createdAt;
  DateTime updatedAt;
  bool selected = false;
  List<ProductList> productslists = [];

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
        id: json["id"],
        name: json["name"],
        shortName: json["short_name"],
        photo: json["photo"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_name": shortName,
        "photo": photo,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
