import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:campdavid/src/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../helpers/packageslist.dart';
import '../helpers/productlists.dart';
import '../helpers/productscontroller.dart';

class ProductsPage extends GetWidget<ProductController> {
  const ProductsPage({super.key});

  @override
  Widget build(context) => GetBuilder<ProductController>(
      builder: (_) => Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              height: getHeight(context),
              width: getWidth(context),
              child: SafeArea(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back, size: 30)),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Text(
                          _.selectedCategoryList!.name == "All"
                              ? "All Products"
                              : _.selectedCategoryList!.name,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                        const SizedBox(
                          width: 30,
                        ),
                        InkWell(
                            onTap: () {
                              if (_.ordersList.isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckOutPage(),
                                    ));
                              } else {
                                _.showToast(
                                    "Failed. Please add something to cart",
                                    Colors.red);
                              }
                            },
                            child: Stack(
                              children: [
                                const Icon(Icons.shopping_cart_outlined,
                                    size: 30),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor,
                                      ),
                                      child: Text(
                                        _.ordersList.length.toString(),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                              ],
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade300),
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 35,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Search in Camp David..",
                            style: GoogleFonts.montserrat(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _.productslists.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.76,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                itemCount: _.productslists.length,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    Card(
                                                color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              height: 100,
                                              imageUrl: imageUrl +
                                                  _.productslists[index].photo,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Container(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child: Center(
                                                      child: CircularProgressIndicator(
                                                          color: primaryColor,
                                                          value:
                                                              downloadProgress
                                                                  .progress)),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                _.productslists[index].category
                                                    .name,
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                _.productslists[index].name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    " Ksh",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                  ),
                                                  Text(
                                                    _.productslists[index]
                                                        .sellingPrice,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 18,
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                              .grey.shade400),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Text(
                                                          " Out of Stock",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 10,
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0)
                                                  .copyWith(bottom: 0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: const BorderSide(
                                                      color: Colors.black),
                                                ),
                                                color: _.cartproducts.contains(
                                                        _.productslists[index])
                                                    ? primaryColor
                                                    : Colors.white,
                                                elevation: 3,
                                                child: InkWell(
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

                                                      _.showDialog(
                                                          _.productslists[
                                                              index], context);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Text(
                                                        " Add to Cart",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                            : _.loading
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
                                : Center(
                                    child: Text(
                                      _.selectedCategoryList!.name == "All"
                                          ? "No Items Available"
                                          : "No ${_.selectedCategoryList!.name} Available",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ))
                ],
              )),
            ),
          ));
}
