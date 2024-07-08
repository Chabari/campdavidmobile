import 'dart:async';

import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/helpers/promotionlist.dart';
import 'package:campdavid/helpers/unitlist.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';
import 'cartmodel.dart';
import 'categorylist.dart';
import 'databaseHelper.dart';
import 'packageslist.dart';

class ProductController extends GetxController {
  List<ProductList> productslists = [];

  CategoryList? selectedCategoryList;

  PromotionList? selectedPromotion;

  List<OrderItemsModel> ordersList = [];
  final DBHelper db = DBHelper();
  late FToast fToast;
  List<ProductList> cartproducts = [];
  TagElement? selectedtag;
  final amountController = TextEditingController();
  bool isItemSelected = false;
  bool loading = true;
  final qtyController = TextEditingController();
  PackageList? selectedPackage;

  late BuildContext? context = Get.context;

  bool isProceed = false;

  // .................................................................................
  List<UnitList> unitLists = [];
  List<CategoryList> categorylists = [];
  CategoryList? categoryList;
  String text = "Checkout Ksh ";
  double total = 0;
  bool isLogged = false;

  ProductList? selectedProductList;

  // .................................................................................

  @override
  void onInit() {
    super.onInit();
    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        isLogged = true;
        update();
      }
    });

    db.getAllCarts().then((scans) {
      ordersList.addAll(scans);
      update();
    });

    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (initialized) {
        db.getAllCarts().then((scans) {
          ordersList = scans;
          update();
        });
      }
    });

    getUnits().then((value) {
      unitLists.addAll(value);
      update();
    });
    getcategoryList().then((value) {
      categorylists = value;
      categoryList = categorylists.first;
      categoryList!.selected = true;
      getProducts(categoryList!.id).then((value) {
        if (initialized) {
          loading = false;
          categoryList!.productslists.addAll(value);

          update();
        }
      });
      update();
    });
  }

  Future<List<UnitList>> getUnits() async {
    var url = Uri.parse('${mainUrl}units');
    var response = await http.get(url);
    return unitListFromJson(response.body);
  }

  Future<List<CategoryList>> getcategoryList() async {
    Map<String, dynamic> data = {
      'filer': 'all',
    };
    var url = Uri.parse('${mainUrl}categories');
    var response = await http.post(url,
        headers: {
          'Accept': 'application/json',
          'Access-Control_Allow_Origin': '*'
        },
        body: data);
    if (response.body.isEmpty) {
      return [];
    }
    return categoryListFromJson(response.body);
  }

  Future<List<ProductList>> getProducts(catid) async {
    var url = Uri.parse('${mainUrl}category-products');
    Map<String, dynamic> data = {
      'category_id': catid.toString(),
    };
    var response = await http.post(url,
        headers: {
          'Accept': 'application/json',
          'Access-Control_Allow_Origin': '*'
        },
        body: data);
    if (response.body.isEmpty) {
      return [];
    }
    return productListFromJson(response.body);
  }

  void addCart1(ProductList product, action, context1) async {
    bool added = false;
    String package = "none";
    String packageId = "none";

    ProgressDialog progressDialog1 = ProgressDialog(context1,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);
    await progressDialog1.show();
    if (selectedPackage != null) {
      package = selectedPackage!.packageName;
    }
    if (selectedPackage != null) {
      packageId = selectedPackage!.id.toString();
    }
    if (product.isselected && product.quantity > 0) {
      added = true;
      db.checkexistsItem(product.id.toString(), "none").then((value) {
        if (value.length > 0) {
          var item = value.first;
          OrderItemsModel orderModel = OrderItemsModel(
              id: item['id'],
              amount: item['amount'],
              category: item['category'],
              image: item['image'],
              package: item['package'],
              packageId: item['packageId'],
              productId: item['productId'],
              unitName: item['unitName'],
              productname: item['productname'],
              quantity: product.quantity.toString(),
              tagId: item['tagId'],
              tagName: item['tagName'],
              weight: item['weight']);
          db.updateCart(orderModel);
        } else {
          OrderItemsModel orderModel = OrderItemsModel(
              amount: product.sellingPrice,
              category: product.category.name,
              image: product.photo,
              package: package,
              packageId: packageId,
              productId: product.id.toString(),
              productname: product.name,
              unitName: product.unit.shortName,
              quantity: product.quantity.toString(),
              tagId: "none",
              tagName: "none",
              weight: "1");

          db.newCart(orderModel).then((value) {
            ordersList.clear();
            db.getAllCarts().then((value2) {
              ordersList.addAll(value2);
              update();
            });
          });
        }
      });
    }

    if (amountController.text.isNotEmpty) {
      if (double.parse(amountController.text) <
          double.parse(product.minimumPrice)) {
        await progressDialog1.hide();
        showToast("Amount is too low. Minimum is Ksh 300", Colors.red);
        return;
      }
      added = true;
      double weight = double.parse(amountController.text) /
          double.parse(product.sellingPrice);

      db.checkexistsItem(product.id.toString(), "custom").then((value) {
        if (value.length > 0) {
          var item = value.first;
          OrderItemsModel orderModel = OrderItemsModel(
              id: item['id'],
              amount: amountController.text,
              category: item['category'],
              image: item['image'],
              package: item['package'],
              unitName: item['unitName'],
              packageId: item['packageId'],
              productId: item['productId'],
              productname: item['productname'],
              quantity: "1",
              tagId: item['tagId'],
              tagName: item['tagName'],
              weight: weight.toString());
          db.updateCart(orderModel);
        } else {
          OrderItemsModel orderModel = OrderItemsModel(
              amount: amountController.text,
              category: product.category.name,
              image: product.photo,
              package: package,
              packageId: packageId,
              productId: product.id.toString(),
              productname: product.name,
              quantity: "1",
              unitName: product.unit.shortName,
              tagId: "custom",
              tagName: "none",
              weight: weight.toString());

          db.newCart(orderModel).then((value) {
            ordersList.clear();
            db.getAllCarts().then((value2) {
              ordersList.addAll(value2);
              update();
            });
          });
        }
      });
    }

    for (var itm in product.tags) {
      if (itm.isselected) {
        added = true;
        db
            .checkexistsItem(product.id.toString(), itm.id.toString())
            .then((value) {
          if (value.length > 0) {
            var item = value.first;
            OrderItemsModel orderModel = OrderItemsModel(
                id: item['id'],
                amount: item['amount'],
                category: item['category'],
                image: item['image'],
                package: item['package'],
                packageId: item['packageId'],
                unitName: item['unitName'],
                productId: item['productId'],
                productname: item['productname'],
                quantity: itm.quantity.toString(),
                tagId: item['tagId'],
                tagName: item['tagName'],
                weight: "1");
            db.updateCart(orderModel);
          } else {
            OrderItemsModel orderModel = OrderItemsModel(
                amount: itm.price,
                category: product.category.name,
                image: product.photo,
                package: package,
                packageId: packageId,
                productId: product.id.toString(),
                productname: product.name,
                unitName: product.unit.shortName,
                quantity: itm.quantity.toString(),
                tagId: itm.id.toString(),
                tagName: itm.tag.name,
                weight: "1");

            db.newCart(orderModel).then((value) {
              ordersList.clear();
              db.getAllCarts().then((value2) {
                ordersList.addAll(value2);
                update();
              });
            });
          }
        });
      }
    }
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      await progressDialog1.hide();
      if (added) {
        if (action == 'checkout') {
          Navigator.push(
              context1,
              MaterialPageRoute(
                builder: (context) => CheckOutPage(),
              ));
        } else {
          showToast("Items aded to cart", Colors.green);
          Navigator.pop(context1);
        }
      } else {
        showToast("No items added to cart. Please select items", Colors.red);
      }
    });
  }

  void setItems(ProductList product) {
    amountController.text = "";
    selectedtag = null;
    qtyController.text = product.minimumQuantity;
    selectedPackage = null;
    update();
  }

  void updateclickItems(ProductList product) {
    amountController.text = "";
    isItemSelected = false;
    selectedtag = null;
    qtyController.text = product.minimumQuantity;
    selectedPackage = null;
    update();
  }

  void showToast(message, color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void addCart(ProductList product, action, context1) async {
    bool added = false;
    String package = "none";
    String packageId = "none";

    late ProgressDialog progressDialog1 = ProgressDialog(context1,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);

    await progressDialog1.show();
    if (selectedPackage != null) {
      package = selectedPackage!.packageName;
    }
    if (selectedPackage != null) {
      packageId = selectedPackage!.id.toString();
    }
    if (product.isselected && product.quantity > 0) {
      added = true;
      db.checkexistsItem(product.id.toString(), "none").then((value) {
        if (value.length > 0) {
          var item = value.first;
          OrderItemsModel orderModel = OrderItemsModel(
              id: item['id'],
              amount: item['amount'],
              category: item['category'],
              image: item['image'],
              package: item['package'],
              packageId: item['packageId'],
              unitName: item['unitName'],
              productId: item['productId'],
              productname: item['productname'],
              quantity: product.quantity.toString(),
              tagId: item['tagId'],
              tagName: item['tagName'],
              weight: item['weight']);
          db.updateCart(orderModel);
        } else {
          OrderItemsModel orderModel = OrderItemsModel(
              amount: product.sellingPrice,
              category: product.category.name,
              image: product.photo,
              package: package,
              unitName: product.unit.shortName,
              packageId: packageId,
              productId: product.id.toString(),
              productname: product.name,
              quantity: product.quantity.toString(),
              tagId: "none",
              tagName: "none",
              weight: "1");

          db.newCart(orderModel).then((value) {
            ordersList.clear();
            db.getAllCarts().then((value2) {
              ordersList.addAll(value2);
              update();
            });
          });
        }
      });
    }

    for (var itm in product.tags) {
      if (itm.isselected) {
        added = true;
        db
            .checkexistsItem(product.id.toString(), itm.id.toString())
            .then((value) {
          if (value.length > 0) {
            var item = value.first;
            OrderItemsModel orderModel = OrderItemsModel(
                id: item['id'],
                amount: item['amount'],
                category: item['category'],
                image: item['image'],
                package: item['package'],
                unitName: item['unitName'],
                packageId: item['packageId'],
                productId: item['productId'],
                productname: item['productname'],
                quantity: itm.quantity.toString(),
                tagId: item['tagId'],
                tagName: item['tagName'],
                weight: "1");
            db.updateCart(orderModel);
          } else {
            OrderItemsModel orderModel = OrderItemsModel(
                amount: itm.price,
                category: product.category.name,
                image: product.photo,
                package: package,
                packageId: packageId,
                unitName: product.unit.shortName,
                productId: product.id.toString(),
                productname: product.name,
                quantity: itm.quantity.toString(),
                tagId: itm.id.toString(),
                tagName: itm.tag.name,
                weight: "1");

            db.newCart(orderModel).then((value) {
              ordersList.clear();
              db.getAllCarts().then((value2) {
                ordersList.addAll(value2);
                update();
              });
            });
          }
        });
      }
    }

    if (amountController.text.isNotEmpty) {
      if (double.parse(amountController.text) <
          double.parse(product.minimumPrice)) {
        await progressDialog1.hide();
        showToast("Amount is too low. Minimum is Ksh 300", Colors.red);
        return;
      }
      added = true;
      double weight = double.parse(amountController.text) /
          double.parse(product.sellingPrice);

      db.checkexistsItem(product.id.toString(), "custom").then((value) {
        if (value.length > 0) {
          var item = value.first;
          OrderItemsModel orderModel = OrderItemsModel(
              id: item['id'],
              amount: amountController.text,
              category: item['category'],
              image: item['image'],
              package: item['package'],
              packageId: item['packageId'],
              unitName: item['unitName'],
              productId: item['productId'],
              productname: item['productname'],
              quantity: "1",
              tagId: item['tagId'],
              tagName: item['tagName'],
              weight: weight.toString());
          db.updateCart(orderModel);
        } else {
          OrderItemsModel orderModel = OrderItemsModel(
              amount: amountController.text,
              category: product.category.name,
              image: product.photo,
              package: package,
              packageId: packageId,
              unitName: product.unit.shortName,
              productId: product.id.toString(),
              productname: product.name,
              quantity: "1",
              tagId: "custom",
              tagName: "none",
              weight: weight.toString());

          db.newCart(orderModel).then((value) {
            ordersList.clear();
            db.getAllCarts().then((value2) {
              ordersList.addAll(value2);
              update();
            });
          });
        }
      });
    }

    Future.delayed(const Duration(seconds: 1)).then((value) async {
      await progressDialog1.hide();
      if (added) {
        if (action == 'checkout') {
          Navigator.push(
              context1,
              MaterialPageRoute(
                builder: (context) => CheckOutPage(),
              ));
        } else {
          showToast("Items aded to cart", Colors.green);
          Navigator.pop(context1);
        }
      } else {
        showToast("No items added to cart. Please select items", Colors.red);
      }
    });
  }

  void showDialog(ProductList product, BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32), topRight: Radius.circular(32))),
      builder: (BuildContext context) {
        return GetBuilder<ProductController>(
            builder: (_) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32)),
                    ),
                    height: product.unit.allowDecimal == 1 ? 520 : 450,
                    child: Column(
                      children: [
                        SizedBox(
                          height: product.unit.allowDecimal == 1 ? 370 : 320,
                          width: getWidth(context),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Select Item',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(Icons.clear))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      // border: Border.fromBorderSide(top)
                                      borderRadius: BorderRadius.circular(20),
                                      color: product.isselected
                                          ? primaryColor.withOpacity(0.1)
                                          : product.stock < 1
                                              ? Colors.grey.shade200
                                              : Colors.white),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              "1 ${product.unit.name}",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                              ),
                                            )),
                                            InkWell(
                                              onTap: () {
                                                if (product.quantity >
                                                    double.parse(product
                                                        .minimumQuantity)) {
                                                  product.quantity--;
                                                  product.isselected = true;
                                                  _.update();
                                                } else {
                                                  product.quantity = 0;
                                                  product.isselected = false;
                                                  _.update();
                                                }
                                              },
                                              child: const Card(
                                                color: Colors.white,
                                                child: Icon(Icons
                                                    .remove_circle_outline),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              product.isselected == false
                                                  ? "0"
                                                  : product.quantity.toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (product.stock < 1) {
                                                  _.showToast(
                                                      "Failed. The product is out of stock.",
                                                      Colors.red);
                                                } else {
                                                  if (product.isselected ==
                                                      false) {
                                                    product.quantity =
                                                        double.parse(product
                                                            .minimumQuantity);
                                                    product.isselected = true;
                                                    _.update();
                                                  } else {
                                                    if (product.stock <=
                                                        double.parse(product
                                                            .quantity
                                                            .toString())) {
                                                      _.showToast(
                                                          "Quantity entered is higher than the available stock.",
                                                          Colors.red);
                                                    } else {
                                                      product.quantity++;
                                                      product.isselected = true;
                                                      _.update();
                                                    }
                                                  }
                                                }
                                              },
                                              child: const Card(
                                                color: Colors.white,
                                                child: Icon(Icons
                                                    .add_circle_outline_sharp),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.isselected == false
                                                    ? "Ksh ${product.sellingPrice}"
                                                    : " ${product.quantity} * ${product.sellingPrice}",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              product.isselected == false
                                                  ? ""
                                                  : "Ksh ${double.parse(product.sellingPrice) * product.quantity}",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: product.tags.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.only(top: 0, bottom: 8),
                                  itemBuilder: (context, ind) => Container(
                                    padding: const EdgeInsets.all(6),
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                        // border: Border.fromBorderSide(top)
                                        borderRadius: BorderRadius.circular(20),
                                        color: product.tags[ind].isselected
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.white),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ...............
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                product.tags[ind].tag.name,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                ),
                                              )),
                                              InkWell(
                                                onTap: () {
                                                  if (product
                                                          .tags[ind].quantity >
                                                      double.parse(product
                                                          .minimumQuantity)) {
                                                    product
                                                        .tags[ind].quantity--;
                                                    product.tags[ind]
                                                        .isselected = true;
                                                    _.update();
                                                  } else {
                                                    product.tags[ind].quantity =
                                                        0;
                                                    product.tags[ind]
                                                        .isselected = false;
                                                    _.update();
                                                  }
                                                },
                                                child: const Card(
                                                color: Colors.white,
                                                  child: Icon(Icons
                                                      .remove_circle_outline),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                product.tags[ind].isselected ==
                                                        false
                                                    ? "0"
                                                    : product.tags[ind].quantity
                                                        .toString(),
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    color: primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (product.tags[ind]
                                                          .isselected ==
                                                      false) {
                                                    product.tags[ind].quantity =
                                                        double.parse(product
                                                            .minimumQuantity);
                                                    product.tags[ind]
                                                        .isselected = true;
                                                  } else {
                                                    if (product
                                                            .tags[ind].stock <=
                                                        product.tags[ind]
                                                            .quantity) {
                                                    } else {
                                                      product.tags[ind]
                                                          .isselected = true;
                                                      product
                                                          .tags[ind].quantity++;
                                                    }
                                                  }
                                                  // }
                                                },
                                                child: const Card(
                                                color: Colors.white,
                                                  child: Icon(Icons
                                                      .add_circle_outline_sharp),
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.tags[ind]
                                                              .isselected ==
                                                          false
                                                      ? "Ksh ${product.tags[ind].price}"
                                                      : " ${product.tags[ind].quantity} * ${product.tags[ind].price}",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                product.tags[ind].isselected ==
                                                        false
                                                    ? ""
                                                    : "Ksh ${double.parse(product.tags[ind].price) * product.tags[ind].quantity}",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // .......................
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (product.unit.allowDecimal == 1)
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        color: Colors.black,
                                        height: 1,
                                      )),
                                      Text(
                                        "Or",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                        color: Colors.black,
                                        height: 1,
                                      )),
                                    ],
                                  ),
                                if (product.unit.allowDecimal == 1)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(top: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Specify Amount (Minimum Ksh ${product.minimumPrice})",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                        // Text(
                                        //   "Qty",
                                        //   style: GoogleFonts
                                        //       .montserrat(
                                        //     fontSize:
                                        //         12,
                                        //   ),
                                        // ),
                                        // const SizedBox(
                                        //   width: 40,
                                        // ),
                                        // Text(
                                        //   "Action",
                                        //   style: GoogleFonts.montserrat(
                                        //     fontSize: 12,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                if (product.unit.allowDecimal == 1)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(top: 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color: primaryColor)),
                                            child: TextFormField(
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    if (int.parse(
                                                                value.trim()) >
                                                            500 &&
                                                        int.parse(
                                                                value.trim()) <
                                                            300000) {}
                                                  }
                                                },
                                                controller: _.amountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 0,
                                                            bottom: 8),
                                                    hintText: "Amount",
                                                    labelText: "Enter amount",
                                                    labelStyle:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                    border: InputBorder.none,
                                                    hintStyle: GoogleFonts.lato(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                                style: GoogleFonts.lato(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),

                                        // InkWell(
                                        //   onTap: () {},
                                        //   child: Container(
                                        //     height: 45,
                                        //     width: 90,
                                        //     padding: const EdgeInsets.all(12),
                                        //     decoration: BoxDecoration(
                                        //         borderRadius:
                                        //             BorderRadius.circular(15),
                                        //         color: Colors.white,
                                        //         boxShadow: [
                                        //           BoxShadow(
                                        //             color: Colors.grey.shade300,
                                        //             blurRadius: 5,
                                        //           )
                                        //         ]),
                                        //     child: Center(
                                        //       child: Text("Add Cart",
                                        //           style: GoogleFonts.lato(
                                        //               fontSize: 14,
                                        //               fontWeight:
                                        //                   FontWeight.bold)),
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),

                                const SizedBox(
                                  height: 10,
                                ),
                                if (product.category.packagingsList.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(bottom: 0),
                                    child: Text(
                                      "Choose how you want your order packaged(Optional)",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (product.category.packagingsList.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: getWidth(context),
                                      height: 45,
                                      child: DropdownButtonFormField2(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          //Add more decoration as you want here
                                          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                        ),
                                        isExpanded: true,
                                        hint: const Text(
                                          'Select Package',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        items: product.category.packagingsList
                                            .map((item) =>
                                                DropdownMenuItem<PackageList>(
                                                  value: item,
                                                  child: Text(
                                                    item.packageName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Please select package.';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          _.selectedPackage =
                                              value as PackageList;
                                          _.update();

                                          //Do something when changing the item if you want.
                                        },
                                        onSaved: (value) {
                                          _.selectedPackage =
                                              value as PackageList;
                                          _.update();
                                        },
                                        buttonStyleData: const ButtonStyleData(
                                          height: 60,
                                          padding: EdgeInsets.only(
                                              left: 20, right: 10),
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black45,
                                          ),
                                          iconSize: 30,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                //
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        InkWell(
                          onTap: () {
                            _.addCart1(product, "checkout", context);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: primaryColor,
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(
                                child: Text(
                                  "Proceed to Checkout",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //const SizedBox(height: 10,),
                        InkWell(
                          onTap: () {
                            _.addCart1(product, "cart", context);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.black,
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(
                                child: Text(
                                  "Add to Cart",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
      },
    );
  }

  bool checkproductelement(var key, ProductList product) {
    return product.customitems.any((element) => element.amount.contains(key));
  }

  void selectCategory() {
    loading = true;

    if (selectedCategoryList!.name == "All") {
      getProducts("all").then((value) {
        loading = false;
        productslists = value;
        update();
      });
    } else {
      getProducts(selectedCategoryList!.id.toString()).then((value) {
        loading = false;
        productslists = value;
        update();
      });
    }
  }
}
