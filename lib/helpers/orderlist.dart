// To parse this JSON data, do
//
//     final orderList = orderListFromJson(jsonString);

import 'dart:convert';

List<OrderList> orderListFromJson(String str) =>
    List<OrderList>.from(json.decode(str).map((x) => OrderList.fromJson(x)));

class OrderList {
  OrderList({
    required this.id,
    required this.orderNumber,
    required this.notes,
    required this.deliveryLocation,
    required this.landmark,
    required this.paymentMethod,
    required this.deliveryFee,
    required this.status,
    required this.isPaid,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.longitude,
    required this.driver,
    required this.driver_phone,
    required this.customer_code,
    required this.latitude,
    required this.order_amount,
    required this.seller,
    required this.orderItems,
    required this.driver_latitude,
    required this.driver_longitude,
    required this.driver_photo,
  });

  int id;
  String orderNumber;
  String notes;
  String deliveryLocation;
  String landmark;
  String paymentMethod;
  String deliveryFee;
  String status;
  String longitude;
  String order_amount;
  String driver;
  String customer_code;
  String latitude;
  String seller;
  int isPaid;
  String driver_photo;
  String driver_phone;
  String total;
  DateTime createdAt;
  DateTime updatedAt;
  String driver_latitude;
  String driver_longitude;

  List<OrderItem> orderItems;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        orderNumber: json["order_number"],
        notes: json["notes"],
        customer_code: json['customer_code'],
        deliveryLocation: json["delivery_location"],
        landmark: json["landmark"],
        paymentMethod: json["payment_method"],
        deliveryFee: json["delivery_fee"],
        order_amount: json['order_amount'].toString(),
        status: json["status"],
        seller: json['seller'],
        driver_photo: json['driver_photo'],
        driver: json['driver'],
        isPaid: json["isPaid"],
        driver_phone: json['driver_phone'],
        driver_latitude: json['driver_longitude'],
        driver_longitude: json['driver_longitude'],
        latitude: json["latitude"],
        longitude: json["longitude"],
        total: json["total"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        orderItems: List<OrderItem>.from(
            json["order_items"].map((x) => OrderItem.fromJson(x))),
      );
}

class OrderItem {
  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitId,
    required this.sellPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  int id;
  String orderId;
  String productId;
  String quantity;
  String unitId;
  String sellPrice;
  DateTime createdAt;
  DateTime updatedAt;
  Product product;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        quantity: json["quantity"],
        unitId: json["unit_id"],
        sellPrice: json["sell_price"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "quantity": quantity,
        "unit_id": unitId,
        "sell_price": sellPrice,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "product": product.toJson(),
      };
}

class Product {
  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) => Product(
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
      );

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
      };
}
