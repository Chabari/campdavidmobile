// To parse this JSON data, do
//
//     final productList = productListFromJson(jsonString);

import 'dart:convert';

import 'package:campdavid/helpers/packageslist.dart';

import 'cartmodel.dart';

List<ProductList> productListFromJson(String str) => List<ProductList>.from(
    json.decode(str).map((x) => ProductList.fromJson(x)));

String productListToJson(List<ProductList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductList {
  ProductList({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.unitId,
    required this.sku,
    required this.photo,
    required this.purchasePrice,
    required this.description,
    required this.sellingPrice,
    required this.currentStock,
    required this.createdAt,
    required this.stock,
    required this.updatedAt,
    required this.category,
    required this.unit,
    required this.isDivisible,
    required this.minimumPrice,
    required this.minimumQuantity,
    required this.quantity,
    required this.tags,
  });

  int id;
  String name;
  String categoryId;
  String unitId;
  String sku;
  String photo;
  String purchasePrice;
  String description;
  String sellingPrice;
  String currentStock;
  int isDivisible;
  String minimumQuantity;
  String minimumPrice;
  double stock;
  DateTime createdAt;
  DateTime updatedAt;
  Category category;
  Unit unit;
  List<TagElement> tags;
  List<OrderItemsModel> customitems = [];
  double quantity;
  bool isselected = false;

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
      id: json["id"],
      name: json["name"],
      minimumQuantity: json['minimum_quantity'] ?? "0",
      categoryId: json["category_id"],
      isDivisible: json['is_divisible'] ?? 0,
      unitId: json["unit_id"] ?? ".",
      stock: json['stock'] != null ? double.parse(json['stock'].toString()) : 0,
      quantity: json['minimum_quantity'] != null ? double.parse(json['minimum_quantity']) : 0,
      sku: json["sku"] ?? ".",
      photo: json["photo"] ?? "none",
      minimumPrice: json['minimum_price'] ?? "0",
      purchasePrice: json["purchase_price"] ?? "0",
      description: json["description"] ?? ".",
      sellingPrice: json["selling_price"] ?? "0",
      currentStock: json["current_stock"] ?? "0",
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      category: Category.fromJson(json["category"]),
      unit: Unit.fromJson(json["unit"]),
      tags: json["tags"].length > 0
          ? List<TagElement>.from(
              json["tags"].map((x) => TagElement.fromJson(x)))
          : []);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category_id": categoryId,
        "unit_id": unitId,
        "sku": sku,
        "photo": photo,
        "purchase_price": purchasePrice,
        "description": description,
        "selling_price": sellingPrice,
        "current_stock": currentStock,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "category": category.toJson(),
        "unit": unit.toJson(),
      };
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.shortName,
    required this.packagingsList,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String shortName;
  List<PackageList> packagingsList;
  DateTime createdAt;
  DateTime updatedAt;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        shortName: json["short_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        packagingsList: json["packages"].length > 0
          ? List<PackageList>.from(
              json["packages"].map((x) => PackageList.fromJson(x)))
          : []
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_name": shortName,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Unit {
  Unit(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.allowDecimal});

  int id;
  String name;
  String shortName;
  int allowDecimal;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
      id: json["id"],
      name: json["name"],
      shortName: json["short_name"],
      allowDecimal: json['allow_decimal']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_name": shortName,
      };
}

class TagElement {
  TagElement({
    required this.id,
    required this.tagId,
    required this.productId,
    required this.price,
    required this.stock,
    required this.tag,
  });

  int id;
  String tagId;
  String productId;
  String price;
  double stock;
  double quantity = 0;
  bool isselected = false;
  TagTag tag;

  factory TagElement.fromJson(Map<String, dynamic> json) => TagElement(
        id: json["id"],
        tagId: json["tag_id"],
        productId: json["product_id"],
        stock: double.parse(json['stock'].toString()),
        price: json["price"],
        tag: TagTag.fromJson(json["tag"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tag_id": tagId,
        "product_id": productId,
        "price": price,
        "tag": tag.toJson(),
      };
}

class TagTag {
  TagTag({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  factory TagTag.fromJson(Map<String, dynamic> json) => TagTag(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
