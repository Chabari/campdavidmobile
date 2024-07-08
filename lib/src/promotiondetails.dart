import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:simple_html_css/simple_html_css.dart';

import '../helpers/productscontroller.dart';

class PromotionDetails extends GetWidget<ProductController> {
  const PromotionDetails({super.key});

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
                                      imageUrl +
                                          _.selectedPromotion!.offerImage,
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
                                        _.selectedPromotion!.offerDescription,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _.selectedPromotion!.selectedProduct!.category
                                      .name,
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      " Ksh",
                                      style: GoogleFonts.montserrat(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 10,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      _.selectedPromotion!.selectedProduct!
                                          .sellingPrice,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          color: primaryColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " / ${_.selectedPromotion!.selectedProduct!.unit.shortName}",
                                      style: GoogleFonts.montserrat(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      " Ksh",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      _.selectedPromotion!.offerPrice,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " / ${_.selectedPromotion!.selectedProduct!.unit.shortName}",
                                      style:
                                          GoogleFonts.montserrat(fontSize: 12),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Colors.grey.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Start Date",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                            ),
                                          )),
                                          Text(
                                            _.selectedPromotion!.offerStartDate,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "End Date",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                            ),
                                          )),
                                          Text(
                                            _.selectedPromotion!.offerEndDate,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Remaining Days",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                            ),
                                          )),
                                          Text(
                                            "${DateTime.now().difference(DateTime.parse(_.selectedPromotion!.offerEndDate)).inDays} Days",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 20,
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

                              // Padding(
                              //     padding: const EdgeInsets.all(8.0)
                              //         .copyWith(top: 0),
                              //     child: Builder(builder: (context) {
                              //       return HTML.toRichText(context,
                              //           _.selectedProductList!.description);
                              //     })),

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
                                // _.setItems(_.selectedProductList!);
                                _.selectedPromotion!.selectedProduct!
                                        .sellingPrice =
                                    _.selectedPromotion!.offerPrice;
                                _.selectedPromotion!.selectedProduct!.name =
                                    _.selectedPromotion!.offerDescription;
                                _.update();

                                _.showDialog(_.selectedPromotion!.selectedProduct!, context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0)
                                    .copyWith(bottom: 0),
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
