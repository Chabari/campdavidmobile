// To parse this JSON data, do
//
//     final productList = productListFromJson(jsonString);

import 'dart:convert';

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
    required this.updatedAt,
    required this.category,
    required this.unit,
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
  DateTime createdAt;
  DateTime updatedAt;
  Category category;
  Category unit;
  List<TagElement> tags;
  int quantity = 1;

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
      id: json["id"],
      name: json["name"],
      categoryId: json["category_id"],
      unitId: json["unit_id"],
      sku: json["sku"],
      photo: json["photo"],
      purchasePrice: json["purchase_price"],
      description: json["description"],
      sellingPrice: json["selling_price"],
      currentStock: json["current_stock"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      category: Category.fromJson(json["category"]),
      unit: Category.fromJson(json["unit"]),
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
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String shortName;
  DateTime createdAt;
  DateTime updatedAt;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
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

class TagElement {
  TagElement({
    required this.id,
    required this.tagId,
    required this.productId,
    required this.price,
    required this.tag,
  });

  int id;
  String tagId;
  String productId;
  String price;
  bool isselected = false;
  TagTag tag;

  factory TagElement.fromJson(Map<String, dynamic> json) => TagElement(
        id: json["id"],
        tagId: json["tag_id"],
        productId: json["product_id"],
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
