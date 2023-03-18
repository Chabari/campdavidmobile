import 'dart:async';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campdavid/helpers/cartmodel.dart';
import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/packageslist.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:campdavid/src/productspage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/databaseHelper.dart';
import '../helpers/homecontroller.dart';

class Home extends StatefulWidget {
  Function(int) screen;
  Function(bool) fetch;
  Home({required this.screen, required this.fetch});
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController ctrl = Get.find();
  String? version;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String buildNumber = packageInfo.buildNumber;
    print(buildNumber);
    if (version != null && int.parse(version!) > int.parse(buildNumber)) {
      _onAlertButtonsPressed(context);
    }
  }

  _onAlertButtonsPressed(context) {
    Alert(
      context: context,
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
          child: Text(
            "CANCEL",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        DialogButton(
          child: Text(
            "UPDATE",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
        )
      ],
    ).show();
  }

  @override
  Widget build(context) => GetBuilder<HomeController>(
      builder: (_) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 20),
                  //decoration: const BoxDecoration(color: primaryColor,borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Categories",
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Explore",
                        style: GoogleFonts.montserrat(),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            widget.screen(1);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: primaryColor),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.arrow_circle_right_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                //const SizedBox(height: 10,),
                _.categorylists.length > 0
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: _.categorylists.length,
                        itemBuilder: (BuildContext context, int index) =>
                            InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                    categoryList: _.categorylists[index]),
                              )),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                    height: 80,
                                    imageUrl: imageUrl +
                                        _.getimage(
                                            _.categorylists[index].photo),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: primaryColor,
                                                value:
                                                    downloadProgress.progress)),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    _.categorylists[index].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 60,
                        width: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 5,
                          ),
                        ),
                      ),

                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 20),
                  //decoration: const BoxDecoration(color: primaryColor,borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Featured Products",
                              style: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Fresh products from Camp David",
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "See All",
                        style: GoogleFonts.montserrat(),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      if (_.categorylists.length > 0)
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                    categoryList: _.categorylists.first),
                              )),
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: primaryColor),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.arrow_circle_right_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _.productslists.length > 0
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.74,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: _.productslists.length,
                        itemBuilder: (BuildContext context, int index) => Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(
                                        productList: _.productslists[index]),
                                  ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  height: 98,
                                  imageUrl: imageUrl +
                                      _.getimage(_.productslists[index].photo),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Container(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              color: primaryColor,
                                              value:
                                                  downloadProgress.progress)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    _.productslists[index].category.name,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    _.productslists[index].name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        " Ksh",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                        _.productslists[index].sellingPrice,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      if (_.productslists[index].stock < 1)
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8),
                                                      bottomLeft:
                                                          Radius.circular(8)),
                                              color: Colors.grey.shade400),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              " Out of Stock",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      //const SizedBox(width: 8,)
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    color: _.cartproducts
                                            .contains(_.productslists[index])
                                        ? primaryColor
                                        : Colors.white,
                                    elevation: 3,
                                    child: InkWell(
                                      onTap: () {
                                        if (_.productslists[index].stock < 1) {
                                          _.showToast(
                                              "Failed. The product is out of stock.",
                                              Colors.red);
                                        } else {
                                          _.updateclickItems(
                                              _.productslists[index]);
                                          showDialog(_.productslists[index]);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            " Add to Cart",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 60,
                        width: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 5,
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ));

  void showDialog(ProductList product) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32), topRight: Radius.circular(32))),
      builder: (BuildContext context) {
        return GetBuilder<HomeController>(
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
                                                child: Icon(
                                                    Icons.remove_circle_outline),
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
                                                  if (product.tags[ind].quantity >
                                                      double.parse(product
                                                          .minimumQuantity)) {
                                                    product.tags[ind].quantity--;
                                                    product.tags[ind].isselected =
                                                        true;
                                                    _.update();
                                                  } else {
                                                    product.tags[ind].quantity =
                                                        0;
                                                    product.tags[ind].isselected =
                                                        false;
                                                    _.update();
                                                  }
                                                },
                                                child: const Card(
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
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (product
                                                          .tags[ind].isselected ==
                                                      false) {
                                                    product.tags[ind].quantity =
                                                        double.parse(product
                                                            .minimumQuantity);
                                                    product.tags[ind].isselected =
                                                        true;
                                                  } else {
                                                    if (product.tags[ind].stock <=
                                                        product
                                                            .tags[ind].quantity) {
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
                                                  product.tags[ind].isselected ==
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
                                                    if (int.parse(value.trim()) >
                                                            500 &&
                                                        int.parse(value.trim()) <
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
                                                            color: Colors.black),
                                                    border: InputBorder.none,
                                                    hintStyle: GoogleFonts.lato(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                                style: GoogleFonts.lato(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)),
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
                                if (product.category.packagingsList.length > 0)
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
                                if (product.category.packagingsList.length > 0)
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
                            _.addCart(product, "checkout", context);
            
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
                            _.addCart(product, "cart", context);
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


}
