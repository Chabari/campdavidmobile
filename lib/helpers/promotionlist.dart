// To parse this JSON data, do
//
//     final unitList = unitListFromJson(jsonString);

import 'dart:convert';

import 'package:campdavid/helpers/productlists.dart';

List<PromotionList> promotionListFromJson(String str) =>
    List<PromotionList>.from(
        json.decode(str).map((x) => PromotionList.fromJson(x)));

class PromotionList {
  PromotionList({
    required this.id,
    required this.isActive,
    required this.offerDays,
    required this.offerDescription,
    required this.offerEndDate,
    required this.offerImage,
    required this.offerPrice,
    required this.offerStartDate,
    required this.productId,
  });

  int id;
  int isActive;
  String offerStartDate;
  String offerEndDate;
  String offerPrice;
  String offerDays;
  String offerImage;
  String offerDescription;
  String productId;
  bool selected = false;
  ProductList? selectedProduct;

  factory PromotionList.fromJson(Map<String, dynamic> json) => PromotionList(
        id: json["id"],
        isActive: json["isActive"],
        offerDays: json["offer_days"],
        offerDescription: json["offer_description"],
        offerEndDate: json["offer_end_date"],
        offerImage: json["offer_image"],
        productId: json["product_id"],
        offerPrice: json["offer_price"],
        offerStartDate: json["offer_start_date"],
      );
}
