import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/searchpagecontroller.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import '../helpers/packageslist.dart';
import '../helpers/productlists.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.put(SearchItemsController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool checkproductelement(var key, ProductList product) {
    return product.customitems.any((element) => element.amount.contains(key));
  }

  @override
  Widget build(context) => GetBuilder<SearchItemsController>(
      builder: (_) => Scaffold(
            body: SizedBox(
              height: getHeight(context),
              width: getWidth(context),
              child: SafeArea(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    margin: const EdgeInsets.all(10).copyWith(top: 5),
                    elevation: 0,
                    color: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      maxLength: 10,
                      onChanged: (value) {
                        _.updateSearchQuery(value);
                        if (value.isEmpty) {
                          _.istyping = false;
                          _.update();
                        }
                      },
                      controller: _.searchEditingController,
                      autofocus: true,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32))),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32))),
                        prefixIcon: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 30,
                              color: Colors.black,
                            )),
                        suffixIcon: InkWell(
                          onTap: () {
                            _.searchText = '';
                            _.searchEditingController.text = '';
                          },
                          child: Icon(
                            Icons.clear,
                            color: _.searchText.isNotEmpty
                                ? Colors.black
                                : Colors.grey.shade200,
                          ),
                        ),
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        hintText: "Search here..",
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _.productslists.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _.productslists.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: const EdgeInsets.all(6),
                                elevation: 3,
                                child: InkWell(
                                  onTap: () {
                                    productCtl.selectedProductList =
                                        _.productslists[index];
                                    productCtl.update();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProductDetails(),
                                        ));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(imageUrl +
                                                    _.productslists[index]
                                                        .photo))),
                                      ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _.productslists[index].name,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (_.productslists[index]
                                                            .stock <
                                                        1) {
                                                      _.showToast(
                                                          "Failed. The product is out of stock.",
                                                          Colors.red);
                                                    } else {
                                                      _.updateclickItems(
                                                          _.productslists[
                                                              index]);
                                                      showDialog(
                                                          _.productslists[
                                                              index]);
                                                    }
                                                  },
                                                  child: Card(
                                                color: Colors.white,
                                                    child: Icon(
                                                      Icons.shopping_cart,
                                                      color: _.cartproducts
                                                              .contains(
                                                                  _.productslists[
                                                                      index])
                                                          ? primaryColor
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  _.productslists[index]
                                                      .category.name,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  " Ksh",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  _.productslists[index]
                                                      .sellingPrice,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18,
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Spacer(),
                                                if (_.productslists[index]
                                                        .stock <
                                                    1)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        8)),
                                                        color: Colors
                                                            .grey.shade300),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        " Out of Stock",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 10,
                                                                color:
                                                                    primaryColor),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : _.istyping
                          ? const SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 5,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "No Products Available",
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                ],
              )),
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
        return GetBuilder<SearchItemsController>(
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
