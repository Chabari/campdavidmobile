// To parse this JSON data, do
//
//     final unitList = unitListFromJson(jsonString);

import 'dart:convert';

List<PackageList> packageListFromJson(String str) =>
    List<PackageList>.from(json.decode(str).map((x) => PackageList.fromJson(x)));


class PackageList {
  PackageList({
    required this.id,
    required this.packageName,
    required this.categoryId,
  });

  int id;
  String packageName;
  String categoryId;
  bool selected = false;

  factory PackageList.fromJson(Map<String, dynamic> json) => PackageList(
        id: json["id"],
        packageName: json["package_name"],
        categoryId: json["category_id"],
      );
}
