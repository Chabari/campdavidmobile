import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/helpers/promotionlist.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';
import 'cartmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'databaseHelper.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'packageslist.dart';

class HomeController extends GetxController {
  var currentIndex = 0;
  List<CategoryList> categorylists = [];
  List<ProductList> productslists = [];
  List<ProductList> cartproducts = [];
  String? version;
  // var context = Get.context;

  List<OrderItemsModel> ordersList = [];
  List<PromotionList> promotionsLists = [];
  final DBHelper _db = DBHelper();
  String selectedprice = "";
  TagElement? selectedtag;

  bool isItemSelected = false;
  final amountController = TextEditingController();
  final qtyController = TextEditingController();
  PackageList? selectedPackage;

  late ProgressDialog progressDialog1;
  late BuildContext? context = Get.context;

  PageController pageController = PageController();
  void setScreen(index) {
    currentIndex = index;
    update();
  }

  List<Widget> imageSliders = [];
  Future<List<PromotionList>> getPromotionsList() async {
    var url = Uri.parse('${mainUrl}getPromotionsList');

    var response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Access-Control_Allow_Origin': '*'
    });
    return promotionListFromJson(response.body);
  }

  void selectPromotion(PromotionList promo) async {
    var progressDialog = ProgressDialog(Get.context!,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);

    var data = {'product_id': promo.productId};
    var body = json.encode(data);
    var response = await http.post(Uri.parse("${mainUrl}getProductDetails"),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: body);
    await progressDialog.hide();
    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      promo.selectedProduct = ProductList.fromJson(json1['product']);
      productCtl.selectedPromotion = promo;
      productCtl.update();

      Get.toNamed('/promotion-details');
    } else {
      showToast(json1['message'], Colors.red);
    }
  }

  void deleteCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
  }

  void deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (promotionsLists.isEmpty) {
      getPromotionsList().then((value) {
        promotionsLists.addAll(value);
        update();
        imageSliders = promotionsLists
            .map((item) => Container(
                  margin: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: () {
                      selectPromotion(item);
                    },
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        child: Stack(
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: imageUrl + item.offerImage,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 1000.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: primaryColor,
                                          value: downloadProgress.progress)),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                   Center(child: Icon(Icons.image, size: 100, color: Colors.grey.shade200,)),
                            ),
                            // Image.network(imageUrl + item.offerImage,
                            //     fit: BoxFit.cover, width: 1000.0),
                          ],
                        )),
                  ),
                ))
            .toList();
        update();
      });
    }

    if (categorylists.isEmpty) {
      getcategoryList();
      update();
    }

    Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      _db.getAllCarts().then((scans) {
        ordersList = scans;
        update();
      });
    });
    if (productslists.isEmpty) {
      getTopProducts();
      update();
    }

    _db.getAllCarts().then((scans) {
      ordersList = scans;
      update();
    });

    Future.delayed(const Duration(seconds: 1)).then((value) {
      SharedPreferences.getInstance().then((value) {
        if (value.getString('version') != null) {
          version = value.getString('version');
          checkversion();
        }
      });
    });
  }

  void checkversion() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // String buildNumber = packageInfo.buildNumber;
    // if (version != null && int.parse(version!) > int.parse(buildNumber)) {
    //   onAlertButtonsPressed();
    // }
  }

  onAlertButtonsPressed() {
    Alert(
      context: Get.context!,
      type: AlertType.warning,
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: GoogleFonts.lato(
            color: primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
        descStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 18),
      ),
      title: "Update Alert!",
      desc:
          "Please update Camp David Butchey app to expirience more and great features",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(Get.context!),
          color: Colors.black,
          child: Text(
            "CANCEL",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.pop(Get.context!);
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
          child: Text(
            "UPDATE",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }

  void getTopProducts() async {
    var url = Uri.parse('${mainUrl}top-products');
    var response = await http.get(url);
    if (response.body.isNotEmpty) {
      productslists = productListFromJson(response.body);
      update();
    }
  }

  void getcategoryList() async {
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
    if (response.body.isNotEmpty) {
      categorylists = categoryListFromJson(response.body);
      update();
    }
  }

  void animateTo(index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  bool doesItContainKey(var key) {
    return ordersList.any((element) => element.productId.contains(key));
  }

  bool checkproductelement(var key, ProductList product) {
    return product.customitems.any((element) => element.amount.contains(key));
  }

  String getimage(String url) {
    if (url.contains('public')) {
      return url.replaceFirst(RegExp('public/'), '');
    }
    return url;
  }

  void updateclickItems(ProductList product) {
    amountController.text = "";
    isItemSelected = false;
    selectedprice = "";
    selectedPackage = null;
    selectedtag = null;
    qtyController.text = product.minimumQuantity;
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
    progressDialog1 = ProgressDialog(context1,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);
    bool added = false;
    String package = "none";
    String packageId = "none";

    await progressDialog1.show();
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
              productname: item['productname'],
              quantity: product.quantity.toString(),
              tagId: item['tagId'],
              tagName: item['tagName'],
              unitName: item['unitName'],
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
              quantity: product.quantity.toString(),
              tagId: "none",
              unitName: product.unit.shortName,
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
      if (double.parse(amountController.text) <
          double.parse(product.minimumPrice)) {
        await progressDialog1.hide();
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
              packageId: item['packageId'],
              productId: item['productId'],
              productname: item['productname'],
              quantity: "1",
              tagId: item['tagId'],
              tagName: item['tagName'],
              unitName: item['unitName'],
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
              tagId: "custom",
              tagName: "none",
              unitName: product.unit.shortName,
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
                productId: item['productId'],
                productname: item['productname'],
                quantity: itm.quantity.toString(),
                tagId: item['tagId'],
                tagName: item['tagName'],
                unitName: item['unitName'],
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
                quantity: itm.quantity.toString(),
                tagId: itm.id.toString(),
                tagName: itm.tag.name,
                unitName: product.unit.shortName,
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
}
