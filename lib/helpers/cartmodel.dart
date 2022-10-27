
class OrderItemsModel {
  String amount;
  String quantity;
  String category;
  String productname;
  String productId;
  String image;
  String tag_name;
  String tag_id;
  String tag_price;
  int? id;

  OrderItemsModel(
      {required this.amount,
      required this.category,
      required this.image,
      required this.productId,
      required this.productname,
      required this.tag_name,
      required this.tag_id,
      required this.tag_price,
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
      'tag_name': tag_name,
      'tag_id': tag_id,
      'tag_price': tag_price,
      'quantity': quantity
    };
  }

  factory OrderItemsModel.fromMap(Map<String, dynamic> json) => OrderItemsModel(
      id: json["id"],
      amount: json["amount"],
      category: json["category"],
      image: json["image"],
      productId: json["productId"],
      productname: json["productname"],
      tag_name: json["tag_name"],
      tag_price: json["tag_price"],
      tag_id: json["tag_id"],
      quantity: json["quantity"]);


}
