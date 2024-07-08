// To parse this JSON data, do
//
//     final orderList = orderListFromJson(jsonString);

import 'dart:convert';

List<OrderList> orderListFromJson(String str) =>
    List<OrderList>.from(json.decode(str).map((x) => OrderList.fromJson(x)));

class OrderList {
  OrderList(
      {required this.id,
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
      required this.totalReturned,
      required this.updatedAt,
      required this.longitude,
      required this.driver,
      required this.driver_phone,
      required this.customer_code,
      required this.latitude,
      required this.order_amount,
      required this.seller,
      required this.orderItems,
      required this.cancel_reason,
      required this.cancelled,
      required this.numberPlate,
      required this.friendName,
      required this.friendPhone,
      required this.pickup_time,
      required this.driver_latitude,
      required this.driver_longitude,
      required this.driver_photo,
      required this.isPickup,
      required this.customer_phone});

  int id;
  String orderNumber;
  String notes;
  String deliveryLocation;
  String landmark;
  String paymentMethod;
  String deliveryFee;
  String friendName;
  String friendPhone;
  String status;
  int isPickup;
  String longitude;
  String pickup_time;
  String order_amount;
  String driver;
  String customer_code;
  String latitude;
  String seller;
  int cancelled;
  String cancel_reason;
  int isPaid;
  String driver_photo;
  String driver_phone;
  String total;
  String totalReturned;
  DateTime createdAt;
  String numberPlate;
  DateTime updatedAt;
  String driver_latitude;
  String driver_longitude;
  String customer_phone;

  List<OrderItem> orderItems;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        orderNumber: json["order_number"],
        cancelled: json["cancelled"] ?? 0,
        cancel_reason: json["cancel_reason"] ?? "none",
        notes: json["notes"] ?? "none",
        customer_phone: json['customer_phone'] ?? "none",
        friendName: json['friend_name'] ?? "none",
        friendPhone: json['friend_phone'] ?? "none",
        totalReturned: json['total_returned'] ?? "0",
        customer_code: json['customer_code'] ?? "none",
        deliveryLocation: json["delivery_location"] ?? "none",
        landmark: json["landmark"] ?? "none",
        isPickup: json['isPickup'] ?? 0,
        paymentMethod: json["payment_method"] ?? "none",
        pickup_time: json['pickup_time'] ?? "none",
        deliveryFee: json["delivery_fee"] ?? "0",
        order_amount: json['order_amount'].toString(),
        status: json["status"] ?? "none",
        numberPlate: json['driver_plate'] ?? "none",
        seller: json['seller'] ?? "none",
        driver_photo: json['driver_photo'] ?? "none",
        driver: json['driver']  ?? "none",
        isPaid: json["isPaid"] ?? 0,
        driver_phone: json['driver_phone'] ?? "none",
        driver_latitude: json['driver_longitude'] ?? "0.0",
        driver_longitude: json['driver_longitude'] ?? "0.0",
        latitude: json["latitude"] ?? "0.0",
        longitude: json["longitude"] ?? "0.0",
        total: json["total"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        orderItems: json["order_items"] != null ? List<OrderItem>.from(
            json["order_items"].map((x) => OrderItem.fromJson(x))) : [],
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
    required this.weight,
    required this.updatedAt,
    required this.totalReturned,
    required this.product,
    required this.item,
    required this.category,
  });

  int id;
  String orderId;
  String productId;
  String quantity;
  String weight;
  String unitId;
  String item;
  String totalReturned;
  String category;
  String sellPrice;
  DateTime createdAt;
  DateTime updatedAt;
  Product product;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        quantity: json["quantity"],
        totalReturned: json["total_returned"],
        unitId: json["unit_id"],
        weight: json['weight'],
        item: json['item'],
        category: json['category'],
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
    required this.unitShort,
    required this.sellingPrice,
    required this.currentStock,
  });

  int id;
  String name;
  String categoryId;
  String unitId;
  String sku;
  String unitShort;
  String photo;
  String purchasePrice;
  String description;
  String sellingPrice;
  String currentStock;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        categoryId: json["category_id"],
        unitId: json["unit_id"] ?? "none",
        sku: json["sku"] ?? "none",
        unitShort: json['unit_short'] ?? "Pcs",
        photo: json["photo"] ?? "none",
        purchasePrice: json["purchase_price"] ?? "0",
        description: json["description"] ?? "none",
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
