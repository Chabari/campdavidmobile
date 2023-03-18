class OrderItemsModel {
  String amount;
  String quantity;
  String category;
  String productname;
  String productId;
  String image;
  String package;
  String packageId;
  String weight;
  String tagName;
  String tagId;
  String unitName;
  int? id;

  OrderItemsModel(
      {required this.amount,
      required this.category,
      required this.image,
      required this.productId,
      required this.package,
      required this.unitName,
      required this.productname,
      required this.packageId,
      required this.weight,
      required this.tagName,
      required this.tagId,
      this.id,
      required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'image': image,
      'productId': productId,
      'productname': productname,
      'unitName': unitName,
      'tagName': tagName,
      'package': package,
      'tagId': tagId,
      'packageId': packageId,
      'weight': weight,
      'quantity': quantity
    };
  }

  factory OrderItemsModel.fromMap(Map<String, dynamic> json) => OrderItemsModel(
      id: json["id"],
      amount: json["amount"],
      category: json["category"],
      package: json['package'] ?? "none",
      image: json["image"],
      productId: json["productId"],
      productname: json["productname"],
      unitName: json['unitName'],
      tagName: json["tagName"],
      packageId: json['packageId'],
      tagId: json["tagId"],
      weight: json["weight"],
      quantity: json["quantity"]);
}
