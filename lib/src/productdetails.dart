import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/helpers/unitlist.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/login.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';
import '../helpers/packageslist.dart';
import '../helpers/productdetailscontroller.dart';

class ProductDetails extends StatefulWidget {
  ProductList productList;

  ProductDetails({required this.productList});
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final controller = Get.put(ProductDetailsController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        controller.isLogged = true;
        controller.update();
      }
    });

    controller.total = double.parse(widget.productList.sellingPrice);
    controller.update();
  }

  bool checkproductelement(var key, ProductList product) {
    return product.customitems.any((element) => element.amount.contains(key));
  }

  @override
  Widget build(context) => GetBuilder<ProductDetailsController>(
      builder: (_) => Scaffold(
            backgroundColor: primaryColor,
            body: SizedBox(
              height: getHeight(context),
              width: getWidth(context),
              child: SafeArea(
                  child: Stack(
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 230,
                            width: getWidth(context),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                      imageUrl + widget.productList.photo,
                                    ),
                                    fit: BoxFit.cover)),
                          ),
                          Positioned(
                            top: 20,
                            left: 10,
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.arrow_back, size: 35)),
                          )
                        ],
                      ),
                      Expanded(
                          child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32))),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0)
                                    .copyWith(bottom: 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.productList.name,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (widget.productList.stock < 2)
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
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
                                    // InkWell(
                                    //   onTap: () {
                                    //     if (widget.productList.tags.length > 0) {
                                    //       if (selectedtag == null) {
                                    //         _db
                                    //             .checkexistsItem(
                                    //                 widget.productList.id.toString())
                                    //             .then((value) {
                                    //           if (value.length > 0) {
                                    //             Fluttertoast.showToast(
                                    //                 msg: "Cart Updated",
                                    //                 toastLength: Toast.LENGTH_SHORT,
                                    //                 gravity: ToastGravity.TOP,
                                    //                 timeInSecForIosWeb: 1,
                                    //                 backgroundColor: Colors.green,
                                    //                 textColor: Colors.white,
                                    //                 fontSize: 16.0);
                                    //           } else {
                                    //             OrderItemsModel item =
                                    //                 OrderItemsModel(
                                    //               amount:
                                    //                   widget.productList.sellingPrice,
                                    //               category: widget
                                    //                   .productList.category.name,
                                    //               image: widget.productList.photo,
                                    //               productId: widget.productList.id
                                    //                   .toString(),
                                    //               tag_id: "none",
                                    //               tag_name: "none",
                                    //               tag_price: "none",
                                    //               productname:
                                    //                   widget.productList.name,
                                    //               quantity: widget
                                    //                   .productList.quantity
                                    //                   .toString(),
                                    //             );
                                    //             _db.newCart(item).then((value) {
                                    //               Fluttertoast.showToast(
                                    //                   msg: "Item Added to Cart",
                                    //                   toastLength: Toast.LENGTH_SHORT,
                                    //                   gravity: ToastGravity.CENTER,
                                    //                   timeInSecForIosWeb: 1,
                                    //                   backgroundColor: Colors.green,
                                    //                   textColor: Colors.white,
                                    //                   fontSize: 16.0);
                                    //               ordersList.clear();
                                    //               _db.getAllCarts().then((value2) {
                                    //                 setState(() {
                                    //                   ordersList.addAll(value2);
                                    //                 });
                                    //               });
                                    //             });
                                    //           }
                                    //         });
                                    //       } else {
                                    //         _db
                                    //             .checkexistsItem(
                                    //                 "${widget.productList.id}.${selectedtag!.id}")
                                    //             .then((value) {
                                    //           if (value.length > 0) {
                                    //             Fluttertoast.showToast(
                                    //                 msg: "Cart Updated",
                                    //                 toastLength: Toast.LENGTH_SHORT,
                                    //                 gravity: ToastGravity.CENTER,
                                    //                 timeInSecForIosWeb: 1,
                                    //                 backgroundColor: Colors.green,
                                    //                 textColor: Colors.white,
                                    //                 fontSize: 16.0);
                                    //           } else {
                                    //             OrderItemsModel item =
                                    //                 OrderItemsModel(
                                    //               amount:
                                    //                   widget.productList.sellingPrice,
                                    //               category: widget
                                    //                   .productList.category.name,
                                    //               image: widget.productList.photo,
                                    //               productId:
                                    //                   "${widget.productList.id}.${selectedtag!.id}",
                                    //               tag_id: selectedtag!.id.toString(),
                                    //               tag_name: selectedtag!.tag.name,
                                    //               tag_price: selectedtag!.price,
                                    //               productname:
                                    //                   widget.productList.name,
                                    //               quantity: widget
                                    //                   .productList.quantity
                                    //                   .toString(),
                                    //             );
                                    //             _db.newCart(item).then((value) {
                                    //               Fluttertoast.showToast(
                                    //                   msg: "Item Added to Cart",
                                    //                   toastLength: Toast.LENGTH_SHORT,
                                    //                   gravity: ToastGravity.CENTER,
                                    //                   timeInSecForIosWeb: 1,
                                    //                   backgroundColor: Colors.green,
                                    //                   textColor: Colors.white,
                                    //                   fontSize: 16.0);
                                    //               ordersList.clear();
                                    //               _db.getAllCarts().then((value2) {
                                    //                 setState(() {
                                    //                   ordersList.addAll(value2);
                                    //                 });
                                    //               });
                                    //             });
                                    //           }
                                    //         });
                                    //       }
                                    //     } else {
                                    //       _db
                                    //           .checkexistsItem(
                                    //               widget.productList.id.toString())
                                    //           .then((value) {
                                    //         if (value.length > 0) {
                                    //           var item = value.first;
                                    //           OrderItemsModel mitem = OrderItemsModel(
                                    //             id: item['id'],
                                    //             amount: item['amount'],
                                    //             category: item['category'],
                                    //             image: item['image'],
                                    //             productId: item['productId'],
                                    //             productname: item['productname'],
                                    //             tag_id: "none",
                                    //             tag_name: "none",
                                    //             tag_price: "none",
                                    //             quantity:
                                    //                 (int.parse(item['quantity']) + 1)
                                    //                     .toString(),
                                    //           );
                                    //           _db.updateCart(mitem);
                                    //           Fluttertoast.showToast(
                                    //               msg: "Cart Update",
                                    //               toastLength: Toast.LENGTH_SHORT,
                                    //               gravity: ToastGravity.CENTER,
                                    //               timeInSecForIosWeb: 1,
                                    //               backgroundColor: Colors.green,
                                    //               textColor: Colors.white,
                                    //               fontSize: 16.0);
                                    //         } else {
                                    //           OrderItemsModel item = OrderItemsModel(
                                    //             amount:
                                    //                 widget.productList.sellingPrice,
                                    //             category:
                                    //                 widget.productList.category.name,
                                    //             image: widget.productList.photo,
                                    //             productId:
                                    //                 widget.productList.id.toString(),
                                    //             tag_id: "none",
                                    //             tag_name: "none",
                                    //             tag_price: "none",
                                    //             productname: widget.productList.name,
                                    //             quantity: widget.productList.quantity
                                    //                 .toString(),
                                    //           );
                                    //           _db.newCart(item).then((value) {
                                    //             Fluttertoast.showToast(
                                    //                 msg: "Item Added to Cart",
                                    //                 toastLength: Toast.LENGTH_SHORT,
                                    //                 gravity: ToastGravity.CENTER,
                                    //                 timeInSecForIosWeb: 1,
                                    //                 backgroundColor: Colors.green,
                                    //                 textColor: Colors.white,
                                    //                 fontSize: 16.0);
                                    //             ordersList.clear();
                                    //             _db.getAllCarts().then((value2) {
                                    //               setState(() {
                                    //                 ordersList.addAll(value2);
                                    //               });
                                    //             });
                                    //           });
                                    //         }
                                    //       });
                                    //       setState(() {
                                    //         cartproducts.add(widget.productList);
                                    //       });
                                    //     }
                                    //   },
                                    //   child: Padding(
                                    //       padding: const EdgeInsets.all(8.0)
                                    //           .copyWith(bottom: 0),
                                    //       child: Icon(Icons.shopping_cart)),
                                    // ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  widget.productList.category.name,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      " Ksh",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      widget.productList.sellingPrice,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " / ${widget.productList.unit.shortName}",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    // if(widget.productList.minimumPrice != "0" && widget.productList.minimumPrice != "none" )
                                    //     Text(
                                    //       " (Minimum Price Ksh ${widget.productList.minimumPrice} )",
                                    //       style: GoogleFonts.montserrat(
                                    //           fontSize: 10, color: Colors.grey),
                                    //     ),
                                  ],
                                ),
                              ),
                              // add scroll with add button at end
                              if (widget.productList.tags.length > 0)
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 0, top: 20),
                                  child: Text(
                                    "Would you also like to have more options? Select below",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),

                              if (widget.productList.tags.length > 0)
                                Container(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(top: 0),
                                  width: getWidth(context),
                                  height: 52,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              widget.productList.tags.length,
                                          itemBuilder: (context, index) => Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: BorderSide(
                                                    color: widget
                                                            .productList
                                                            .tags[index]
                                                            .isselected
                                                        ? Colors.grey
                                                        : primaryColor)),
                                            color: widget.productList
                                                    .tags[index].isselected
                                                ? Colors.grey
                                                : Colors.white,
                                            child: InkWell(
                                              onTap: () {
                                                widget.productList.tags.forEach(
                                                  (element) {
                                                    if (element.id !=
                                                            widget
                                                                .productList
                                                                .tags[index]
                                                                .id &&
                                                        element.isselected) {
                                                      element.isselected =
                                                          false;
                                                      _.update();
                                                    }
                                                  },
                                                );
                                                widget.productList.tags[index]
                                                        .isselected =
                                                    !widget.productList
                                                        .tags[index].isselected;
                                                _.update();
                                                if (widget.productList
                                                    .tags[index].isselected) {
                                                  _.total = double.parse(widget
                                                      .productList
                                                      .tags[index]
                                                      .price);
                                                  _.selectedtag = widget
                                                      .productList.tags[index];
                                                  _.update();
                                                } else {
                                                  _.total = double.parse(widget
                                                      .productList
                                                      .sellingPrice);
                                                  _.selectedtag = null;
                                                  _.update();
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "${widget.productList.tags[index].tag.name} - Ksh ${widget.productList.tags[index].price}",
                                                  style: GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Card(
                                        //   shape: RoundedRectangleBorder(
                                        //       borderRadius: BorderRadius.circular(10),
                                        //       side: const BorderSide(color: primaryColor)),
                                        //   color: Colors.white,
                                        //   child: const Padding(
                                        //     padding: EdgeInsets.all(5.0),
                                        //     child: Icon(
                                        //       Icons.add_circle,
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),

                              // Padding(
                              //   padding: const EdgeInsets.all(8.0).copyWith(top: 10),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: Container(
                              //           height: 45,
                              //           decoration: BoxDecoration(
                              //               borderRadius: BorderRadius.circular(20),
                              //               border: Border.all(color: primaryColor)),
                              //           child: TextFormField(
                              //               onChanged: (value) {
                              //                 if (value.isNotEmpty) {
                              //                   if (int.parse(value.trim()) > 500 &&
                              //                       int.parse(value.trim()) < 300000) {

                              //                   }
                              //                 }
                              //               },
                              //               //controller: _amountController,
                              //               keyboardType: TextInputType.number,

                              //               decoration: InputDecoration(
                              //                   contentPadding: const EdgeInsets.only(
                              //                       left: 10, right: 10, top: 0, bottom: 8),
                              //                   hintText: "Quantity",
                              //                   border: InputBorder.none,
                              //                   hintStyle: GoogleFonts.lato(
                              //                       fontSize: 14, color: Colors.grey)),
                              //               style: GoogleFonts.lato(
                              //                   fontSize: 14,
                              //                   color: Colors.black,
                              //                   fontWeight: FontWeight.bold)),
                              //         ),
                              //       ),
                              //       const SizedBox(
                              //         width: 10,
                              //       ),
                              //       InkWell(
                              //         onTap: () {

                              //         },
                              //         child: Container(
                              //           padding: const EdgeInsets.all(15),
                              //           decoration: BoxDecoration(
                              //               shape: BoxShape.circle, color: Colors.white,
                              //               boxShadow: [BoxShadow(
                              //                 color: Colors.grey.shade300,
                              //                 blurRadius: 5,

                              //               )]
                              //               ),
                              //           child: Center(
                              //             child: Text("OK",
                              //                 style: GoogleFonts.lato(
                              //                     fontSize: 14,
                              //                     fontWeight: FontWeight.bold)),
                              //           ),
                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // ),

                              const SizedBox(
                                height: 10,
                              ),
                              if (widget.productList.description != "none" &&
                                  widget.productList.description != "N/A" &&
                                  widget.productList.description != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 0),
                                  child: Text(
                                    "Description",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (widget.productList.description != "none" &&
                                  widget.productList.description != "N/A" &&
                                  widget.productList.description != null)
                                Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(top: 0),
                                    child: Html(
                                        data: widget.productList.description)),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Explore more products",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                padding: const EdgeInsets.all(10),
                                width: getWidth(context),
                                height: 48,
                                decoration: const BoxDecoration(
                                    color: backGround,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20))),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _.categorylists.length,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                          padding: const EdgeInsets.all(0.0)
                                              .copyWith(right: 10),
                                          child: InkWell(
                                            onTap: () {
                                              _.categorylists
                                                  .forEach((element) {
                                                element.selected = false;
                                                _.update();
                                              });
                                              _.categorylists[index].selected =
                                                  true;
                                              _.categoryList =
                                                  _.categorylists[index];
                                              _.update();
                                              if (_.categoryList != null &&
                                                  _.categoryList!.productslists
                                                          .length <
                                                      1) {
                                                _
                                                    .getProducts(_
                                                        .categorylists[index]
                                                        .id)
                                                    .then((value) {
                                                  _.loading = false;
                                                  _.categoryList!.productslists
                                                      .addAll(value);
                                                  _.update();
                                                });
                                              }
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (_.categorylists[index]
                                                        .selected ==
                                                    false)
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                Text(
                                                  _.categorylists[index].name,
                                                  style: GoogleFonts.montserrat(
                                                      color:
                                                          _.categorylists[index]
                                                                  .selected
                                                              ? primaryColor
                                                              : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                if (_.categorylists[index]
                                                    .selected)
                                                  Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                primaryColor),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _.categoryList != null &&
                                      _.categoryList!.productslists.length > 0
                                  ? ListView.builder(
                                      itemCount:
                                          _.categoryList!.productslists.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        margin: const EdgeInsets.all(6),
                                        elevation: 3,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductDetails(
                                                          productList: _
                                                                  .categoryList!
                                                                  .productslists[
                                                              index]),
                                                ));
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 90,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            imageUrl +
                                                                _
                                                                    .categoryList!
                                                                    .productslists[
                                                                        index]
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            _
                                                                .categoryList!
                                                                .productslists[
                                                                    index]
                                                                .name,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          _
                                                              .categoryList!
                                                              .productslists[
                                                                  index]
                                                              .category
                                                              .name,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          " Ksh",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                        Text(
                                                          _
                                                              .categoryList!
                                                              .productslists[
                                                                  index]
                                                              .sellingPrice,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 18,
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : _.loading
                                      ? Container(
                                          alignment: Alignment.center,
                                          child: const SizedBox(
                                            height: 60,
                                            width: 60,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: primaryColor,
                                                strokeWidth: 5,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _.categoryList != null
                                                ? "No ${_.categoryList!.name} Available"
                                                : "No Products Available",
                                            style: GoogleFonts.montserrat(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),

                              const SizedBox(
                                height: 80,
                              )
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (widget.productList.stock < 2) {
                                  _.showToast(
                                      "Failed. The product is out of stock.",
                                      Colors.red);
                                } else {
                                  _.setItems(widget.productList);

                                  showDialog(widget.productList);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0)
                                    .copyWith(bottom: 0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: widget.productList.stock < 2
                                      ? Colors.grey.shade500
                                      : primaryColor,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
        return GetBuilder<ProductDetailsController>(
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
