import 'dart:async';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/helpers/unitlist.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/constants.dart';
import 'cartmodel.dart';
import 'databaseHelper.dart';
import 'packageslist.dart';

class ProductDetailsController extends GetxController {
  List<UnitList> unitLists = [];
  List<CategoryList> categorylists = [];
  CategoryList? categoryList;
  bool loading = true;
  final DBHelper _db = DBHelper();
  List<ProductList> cartproducts = [];
  List<OrderItemsModel> ordersList = [];
  late FToast fToast;
  final amountController = TextEditingController();
  final qtyController = TextEditingController();
  TagElement? selectedtag;
  String text = "Checkout Ksh ";
  PackageList? selectedPackage;
  double total = 0;
  bool isLogged = false;

  late BuildContext? context = Get.context;
  late ArsProgressDialog progressDialog1 = ArsProgressDialog(context,
      blur: 2,
      backgroundColor: const Color(0x33000000),
      animationDuration: const Duration(milliseconds: 500));

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    _db.getAllCarts().then((scans) {
      ordersList.addAll(scans);
      update();
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
    _db.getAllCarts().then((scans) {
      ordersList.addAll(scans);
      update();
    });

    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (initialized) {
        _db.getAllCarts().then((scans) {
          ordersList = scans;
          update();
        });
      }
    });
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

  void addCart(ProductList product, action, context1) {
    bool added = false;
    String package = "none";
    String packageId = "none";
    ArsProgressDialog progressDialog = ArsProgressDialog(context1,
      blur: 2,
      backgroundColor: const Color(0x33000000),
      animationDuration: const Duration(milliseconds: 500));
    progressDialog.show();
    if (selectedPackage != null) {
      package = selectedPackage!.packageName;
    }
    if (selectedPackage != null) {
      packageId = selectedPackage!.id.toString();
    }
    if (product.isselected && product.quantity > 0) {
      added = true;
      _db.checkexistsItem(product.id.toString(), "none").then((value) {
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
          _db.updateCart(orderModel);
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

          _db.newCart(orderModel).then((value) {
            ordersList.clear();
            _db.getAllCarts().then((value2) {
              ordersList.addAll(value2);
              update();
            });
          });
        }
      });
    }

    if (amountController.text.isNotEmpty) {
      if (double.parse(amountController.text) < double.parse(product.minimumPrice)) {
        progressDialog.dismiss();
        showToast("Amount is too low. Minimum is Ksh 300", Colors.red);
        return;
      }
      added = true;
      double weight = double.parse(amountController.text) /
          double.parse(product.sellingPrice);

      _db.checkexistsItem(product.id.toString(), "custom").then((value) {
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
          _db.updateCart(orderModel);
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

          _db.newCart(orderModel).then((value) {
            ordersList.clear();
            _db.getAllCarts().then((value2) {
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
        _db
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
            _db.updateCart(orderModel);
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

            _db.newCart(orderModel).then((value) {
              ordersList.clear();
              _db.getAllCarts().then((value2) {
                ordersList.addAll(value2);
                update();
              });
            });
          }
        });
      }
    }
    Future.delayed(const Duration(seconds: 1)).then((value) {
      progressDialog.dismiss();
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
}
