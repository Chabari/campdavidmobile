import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:simple_html_css/simple_html_css.dart';

import '../helpers/productscontroller.dart';

class ProductDetails extends GetWidget<ProductController> {
  const ProductDetails({super.key});

  @override
  Widget build(context) => GetBuilder<ProductController>(
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
                                      imageUrl + _.selectedProductList!.photo,
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
                                        _.selectedProductList!.name,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (_.selectedProductList!.stock < 2)
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
                                    //     if (_.selectedProductList!.tags.length > 0) {
                                    //       if (selectedtag == null) {
                                    //         _db
                                    //             .checkexistsItem(
                                    //                 _.selectedProductList!.id.toString())
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
                                    //                   _.selectedProductList!.sellingPrice,
                                    //               category: widget
                                    //                   .productList.category.name,
                                    //               image: _.selectedProductList!.photo,
                                    //               productId: _.selectedProductList!.id
                                    //                   .toString(),
                                    //               tag_id: "none",
                                    //               tag_name: "none",
                                    //               tag_price: "none",
                                    //               productname:
                                    //                   _.selectedProductList!.name,
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
                                    //                 "${_.selectedProductList!.id}.${selectedtag!.id}")
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
                                    //                   _.selectedProductList!.sellingPrice,
                                    //               category: widget
                                    //                   .productList.category.name,
                                    //               image: _.selectedProductList!.photo,
                                    //               productId:
                                    //                   "${_.selectedProductList!.id}.${selectedtag!.id}",
                                    //               tag_id: selectedtag!.id.toString(),
                                    //               tag_name: selectedtag!.tag.name,
                                    //               tag_price: selectedtag!.price,
                                    //               productname:
                                    //                   _.selectedProductList!.name,
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
                                    //               _.selectedProductList!.id.toString())
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
                                    //                 _.selectedProductList!.sellingPrice,
                                    //             category:
                                    //                 _.selectedProductList!.category.name,
                                    //             image: _.selectedProductList!.photo,
                                    //             productId:
                                    //                 _.selectedProductList!.id.toString(),
                                    //             tag_id: "none",
                                    //             tag_name: "none",
                                    //             tag_price: "none",
                                    //             productname: _.selectedProductList!.name,
                                    //             quantity: _.selectedProductList!.quantity
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
                                    //         cartproducts.add(_.selectedProductList!);
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
                                  _.selectedProductList!.category.name,
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
                                      _.selectedProductList!.sellingPrice,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " / ${_.selectedProductList!.unit.shortName}",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    // if(_.selectedProductList!.minimumPrice != "0" && _.selectedProductList!.minimumPrice != "none" )
                                    //     Text(
                                    //       " (Minimum Price Ksh ${_.selectedProductList!.minimumPrice} )",
                                    //       style: GoogleFonts.montserrat(
                                    //           fontSize: 10, color: Colors.grey),
                                    //     ),
                                  ],
                                ),
                              ),
                              // add scroll with add button at end
                              if (_.selectedProductList!.tags.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 0, top: 20),
                                  child: Text(
                                    "Would you also like to have more options? Select below",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),

                              if (_.selectedProductList!.tags.isNotEmpty)
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
                                          itemCount: _
                                              .selectedProductList!.tags.length,
                                          itemBuilder: (context, index) => Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: BorderSide(
                                                    color: _
                                                            .selectedProductList!
                                                            .tags[index]
                                                            .isselected
                                                        ? Colors.grey
                                                        : primaryColor)),
                                            color: _.selectedProductList!
                                                    .tags[index].isselected
                                                ? Colors.grey
                                                : Colors.white,
                                            child: InkWell(
                                              onTap: () {
                                                for (var element in _
                                                    .selectedProductList!
                                                    .tags) {
                                                  if (element.id !=
                                                          _.selectedProductList!
                                                              .tags[index].id &&
                                                      element.isselected) {
                                                    element.isselected = false;
                                                    _.update();
                                                  }
                                                }
                                                _
                                                        .selectedProductList!
                                                        .tags[index]
                                                        .isselected =
                                                    !_.selectedProductList!
                                                        .tags[index].isselected;
                                                _.update();
                                                if (_.selectedProductList!
                                                    .tags[index].isselected) {
                                                  _.total = double.parse(_
                                                      .selectedProductList!
                                                      .tags[index]
                                                      .price);
                                                  _.selectedtag = _
                                                      .selectedProductList!
                                                      .tags[index];
                                                  _.update();
                                                } else {
                                                  _.total = double.parse(_
                                                      .selectedProductList!
                                                      .sellingPrice);
                                                  _.selectedtag = null;
                                                  _.update();
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "${_.selectedProductList!.tags[index].tag.name} - Ksh ${_.selectedProductList!.tags[index].price}",
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
                              if (_.selectedProductList!.description !=
                                      "none" &&
                                  _.selectedProductList!.description != "N/A" &&
                                  _.selectedProductList!.description != null)
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
                              if (_.selectedProductList!.description !=
                                      "none" &&
                                  _.selectedProductList!.description != "N/A" &&
                                  _.selectedProductList!.description != null)
                                Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(top: 0),
                                    child: Builder(builder: (context) {
                                      return HTML.toRichText(context,
                                          _.selectedProductList!.description);
                                    })),
                              // Padding(
                              //     padding: const EdgeInsets.all(8.0)
                              //         .copyWith(top: 0),
                              //     child: Html(
                              //         data: _.selectedProductList!.description)),
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
                                              for (var element
                                                  in _.categorylists) {
                                                element.selected = false;
                                                _.update();
                                              }
                                              _.categorylists[index].selected =
                                                  true;
                                              _.categoryList =
                                                  _.categorylists[index];
                                              _.update();
                                              if (_.categoryList != null &&
                                                  _.categoryList!.productslists
                                                      .isEmpty) {
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
                                      _.categoryList!.productslists.isNotEmpty
                                  ? ListView.builder(
                                      itemCount:
                                          _.categoryList!.productslists.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => Card(
                                                color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        margin: const EdgeInsets.all(6),
                                        elevation: 3,
                                        child: InkWell(
                                          onTap: () {
                                            _.selectedProductList = _
                                                .categoryList!
                                                .productslists[index];
                                            _.update();

                                            Navigator.pushReplacement(
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
                                if (_.selectedProductList!.stock < 2) {
                                  _.showToast(
                                      "Failed. The product is out of stock.",
                                      Colors.red);
                                } else {
                                  _.setItems(_.selectedProductList!);

                                  _.showDialog(_.selectedProductList!, context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0)
                                    .copyWith(bottom: 0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: _.selectedProductList!.stock < 2
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
}
