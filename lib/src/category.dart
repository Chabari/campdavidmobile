import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';

class Category extends StatefulWidget {
  Function(bool) fetch;
  Category({required this.fetch});
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  int selected = 0;
  List<CategoryList> categorylists = [];
  List<ProductList> cartproducts = [];
  CategoryList? categoryList;
  bool loading = false;
  List<OrderItemsModel> ordersList = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  TagElement? selectedtag;
  bool isItemSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
    getcategoryList().then((value) {
      if (mounted) {
        setState(() {
          categorylists = value;
          categoryList = categorylists.first;
          categoryList!.selected = true;
          loading = true;
          getProducts(categoryList!.id).then((value) {
            if (mounted) {
              setState(() {
                loading = false;
                categoryList!.productslists.addAll(value);
              });
            }
          });
        });
      }
    });
    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
      });
    });
  }

  _showToast(content, IconData icon, color) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<List<CategoryList>> getcategoryList() async {
    Map<String, dynamic> data = {
      'filer': 'cat',
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


  String getimage(String url) {
    if (url.contains('public')) {

      return url.replaceFirst(RegExp('public/'), '');
    }
    return url;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 80,
                    height: getHeight(context),
                    padding: const EdgeInsets.only(bottom: 170),
                    child: categorylists.length > 0
                        ? ListView.builder(
                            itemCount: categorylists.length,
                            padding:
                                const EdgeInsets.only(bottom: 170, top: 10),
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)
                                      .copyWith(
                                          topRight: const Radius.circular(0),
                                          bottomRight:
                                              const Radius.circular(0)),
                                  color: categorylists[index].selected
                                      ? Colors.grey.shade300
                                      : Colors.transparent,
                                ),
                                margin: const EdgeInsets.only(top: 4, left: 8),
                                child: InkWell(
                                  onTap: () {
                                    categorylists.forEach((element) {
                                      setState(() {
                                        element.selected = false;
                                      });
                                    });
                                    setState(() {
                                      categorylists[index].selected = true;
                                      categoryList = categorylists[index];
                                      loading = true;
                                    });
                                    if (categoryList != null &&
                                        categoryList!.productslists.length <
                                            1) {
                                      getProducts(categorylists[index].id)
                                          .then((value) {
                                        setState(() {
                                          loading = false;
                                          categoryList!.productslists
                                              .addAll(value);
                                        });
                                      });
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(imageUrl + getimage(
                                                    categorylists[index]
                                                        .photo)))),
                                        padding: const EdgeInsets.all(15),
                                        width: 50,
                                        height: 50,
                                      ),
                                      Text(
                                        categorylists[index].name,
                                        style: GoogleFonts.cabin(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                          )),
                Container(
                  width: 6,
                  height: getHeight(context),
                  color: Colors.grey.shade300,
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(bottom: 170),
                  height: getHeight(context),
                  child: categoryList != null &&
                          categoryList!.productslists.length > 0
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.57,
                          ),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 170),
                          itemCount: categoryList!.productslists.length,
                          itemBuilder:
                              (BuildContext context, int index) => Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 3,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetails(
                                                      productList: categoryList!
                                                              .productslists[
                                                          index]),
                                            ));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        imageUrl +
                                                            categoryList!
                                                                .productslists[
                                                                    index]
                                                                .photo))),
                                            height: 100,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Text(
                                              categoryList!.productslists[index]
                                                  .category.name,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Text(
                                              categoryList!
                                                  .productslists[index].name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
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
                                                  categoryList!
                                                      .productslists[index]
                                                      .sellingPrice,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18,
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                side: BorderSide(
                                                    color: cartproducts.contains(
                                                            categoryList!
                                                                    .productslists[
                                                                index])
                                                        ? primaryColor
                                                        : Colors.black),
                                              ),
                                              color: cartproducts.contains(
                                                      categoryList!
                                                          .productslists[index])
                                                  ? primaryColor
                                                  : Colors.white,
                                              elevation: 3,
                                              child: InkWell(
                                                onTap: () {
                                                  if (categoryList!
                                                          .productslists[index]
                                                          .tags
                                                          .length >
                                                      0) {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          32),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          32))),
                                                      builder: (BuildContext
                                                          context) {
                                                        return StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setModalState) {
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          32),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          32)),
                                                            ),
                                                            height: 350,
                                                            child: Stack(
                                                              children: [
                                                                SingleChildScrollView(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: <
                                                                        Widget>[
                                                                      const SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Text(
                                                                          'Select Item',
                                                                          style:
                                                                              GoogleFonts.montserrat(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(6),
                                                                        decoration: const BoxDecoration(
                                                                            // border: Border.fromBorderSide(top)
                                                                            ),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            categoryList!.productslists[index].tags.forEach((element) {
                                                                              setModalState(() {
                                                                                element.isselected = false;
                                                                              });
                                                                            });
                                                                            setModalState(() {
                                                                              isItemSelected = true;
                                                                              selectedtag = null;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      isItemSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                                                      size: 30,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 4,
                                                                                    ),
                                                                                    Expanded(
                                                                                        child: Text(
                                                                                      "1 ${categoryList!.productslists[index].unit.name}",
                                                                                      style: GoogleFonts.montserrat(
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    )),
                                                                                    Text(" Ksh ${categoryList!.productslists[index].sellingPrice}", style: GoogleFonts.cabin(fontSize: 18))
                                                                                  ],
                                                                                ),
                                                                                const Divider(
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        itemCount: categoryList!
                                                                            .productslists[index]
                                                                            .tags
                                                                            .length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                8,
                                                                            bottom:
                                                                                30),
                                                                        itemBuilder:
                                                                            (context, ind) =>
                                                                                Container(
                                                                          padding:
                                                                              const EdgeInsets.all(6),
                                                                          decoration: const BoxDecoration(
                                                                              // border: Border.fromBorderSide(top)
                                                                              ),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              categoryList!.productslists[index].tags.forEach((element) {
                                                                                setModalState(() {
                                                                                  element.isselected = false;
                                                                                });
                                                                              });
                                                                              setModalState(() {
                                                                                isItemSelected = false;
                                                                                categoryList!.productslists[index].tags[ind].isselected = true;
                                                                                selectedtag = categoryList!.productslists[index].tags[ind];
                                                                              });
                                                                            },
                                                                            child:
                                                                                Center(
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        child: Icon(
                                                                                          categoryList!.productslists[index].tags[ind].isselected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                                                          size: 30,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 4,
                                                                                      ),
                                                                                      Expanded(
                                                                                          child: Container(
                                                                                        child: Text(
                                                                                          categoryList!.productslists[index].tags[ind].tag.name,
                                                                                          style: GoogleFonts.montserrat(
                                                                                            fontSize: 18,
                                                                                          ),
                                                                                        ),
                                                                                      )),
                                                                                      Text(" Ksh ${categoryList!.productslists[index].tags[ind].price}", style: GoogleFonts.cabin(fontSize: 18))
                                                                                    ],
                                                                                  ),
                                                                                  const Divider(
                                                                                    color: Colors.grey,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child:
                                                                      Container(
                                                                    width: getWidth(
                                                                        context),
                                                                    child: Row(
                                                                      children: [
                                                                        // Container(
                                                                        //   child: InkWell(
                                                                        //     onTap: () {},
                                                                        //     child: Container(
                                                                        //       decoration:
                                                                        //           BoxDecoration(
                                                                        //         border: Border.all(
                                                                        //             color:
                                                                        //                 primaryColor),
                                                                        //         borderRadius:
                                                                        //             BorderRadius
                                                                        //                 .circular(
                                                                        //                     10),
                                                                        //       ),
                                                                        //       padding:
                                                                        //           const EdgeInsets
                                                                        //               .all(8),
                                                                        //       margin:
                                                                        //           const EdgeInsets
                                                                        //                   .only(
                                                                        //               right:
                                                                        //                   15),
                                                                        //       width: 70,
                                                                        //       child: const Icon(
                                                                        //         Icons
                                                                        //             .add_shopping_cart,
                                                                        //         color:
                                                                        //             primaryColor,
                                                                        //       ),
                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              if (selectedtag != null) {
                                                                                _db.checkexistsItem("${categoryList!.productslists[index].id}.${selectedtag!.id}").then((value) {
                                                                                  if (value.length > 0) {
                                                                                    var item = value.first;
                                                                                    OrderItemsModel mitem = OrderItemsModel(
                                                                                      id: item['id'],
                                                                                      amount: item['amount'],
                                                                                      category: item['category'],
                                                                                      image: item['image'],
                                                                                      productId: item['productId'],
                                                                                      productname: item['productname'],
                                                                                      tag_id: item['tag_id'],
                                                                                      tag_name: item['tag_name'],
                                                                                      tag_price: item['tag_price'],
                                                                                      quantity: (int.parse(item['quantity']) + 1).toString(),
                                                                                    );
                                                                                    _db.updateCart(mitem);
                                                                                    Fluttertoast.showToast(msg: "Cart Updated", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                                                                                    // _showToast("Cart Updated", Icons.check, Colors.green);
                                                                                  } else {
                                                                                    OrderItemsModel item = OrderItemsModel(amount: categoryList!.productslists[index].sellingPrice, category: categoryList!.productslists[index].category.name, image: categoryList!.productslists[index].photo, productId: "${categoryList!.productslists[index].id}.${selectedtag!.id}", productname: categoryList!.productslists[index].name, quantity: categoryList!.productslists[index].quantity.toString(), tag_id: selectedtag!.id.toString(), tag_name: selectedtag!.tag.name, tag_price: selectedtag!.price);
                                                                                    _db.newCart(item).then((value) {
                                                                                      Fluttertoast.showToast(msg: "Item Added to Cart", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                                                                                      // _showToast("Item Added to Cart", Icons.check, Colors.green);
                                                                                      ordersList.clear();
                                                                                      _db.getAllCarts().then((value2) {
                                                                                        setState(() {
                                                                                          ordersList.addAll(value2);
                                                                                          widget.fetch(true);
                                                                                        });
                                                                                      });
                                                                                    });
                                                                                  }
                                                                                });
                                                                              } else {
                                                                                if (isItemSelected) {
                                                                                  setState(() {
                                                                                    cartproducts.add(categoryList!.productslists[index]);
                                                                                  });

                                                                                  _db.checkexistsItem(categoryList!.productslists[index].id.toString()).then((value) {
                                                                                    if (value.length > 0) {
                                                                                      var item = value.first;
                                                                                      OrderItemsModel mitem = OrderItemsModel(
                                                                                        id: item['id'],
                                                                                        amount: item['amount'],
                                                                                        category: item['category'],
                                                                                        image: item['image'],
                                                                                        productId: item['productId'],
                                                                                        productname: item['productname'],
                                                                                        tag_id: item['tag_id'],
                                                                                        tag_name: item['tag_name'],
                                                                                        tag_price: item['tag_price'],
                                                                                        quantity: (int.parse(item['quantity']) + 1).toString(),
                                                                                      );
                                                                                      _db.updateCart(mitem);

                                                                                      // _showToast("Cart Updated", Icons.check,
                                                                                      //     Colors.green);
                                                                                      Fluttertoast.showToast(msg: "Cart Updated", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                                                                                    } else {
                                                                                      OrderItemsModel item = OrderItemsModel(amount: categoryList!.productslists[index].sellingPrice, category: categoryList!.productslists[index].category.name, image: categoryList!.productslists[index].photo, productId: categoryList!.productslists[index].id.toString(), productname: categoryList!.productslists[index].name, quantity: categoryList!.productslists[index].quantity.toString(), tag_id: "none", tag_name: "none", tag_price: "none");
                                                                                      _db.newCart(item).then((value) {
                                                                                        // _showToast("Item Added to Cart",
                                                                                        //     Icons.check, Colors.green);
                                                                                        Fluttertoast.showToast(msg: "Item Added to Cart", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);

                                                                                        ordersList.clear();
                                                                                        _db.getAllCarts().then((value2) {
                                                                                          setState(() {
                                                                                            ordersList.addAll(value2);
                                                                                            widget.fetch(true);
                                                                                          });
                                                                                        });
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                } else {
                                                                                  Fluttertoast.showToast(msg: "Select Item to add to cart", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                                                                                }

                                                                                // _showToast("Select Item to add to cart", Icons.cancel, Colors.red);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Card(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              color: primaryColor,
                                                                              elevation: 3,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    " Add Cart",
                                                                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                      },
                                                    );
                                                  } else {
                                                    setState(() {
                                                      cartproducts.add(
                                                          categoryList!
                                                                  .productslists[
                                                              index]);
                                                    });

                                                    _db
                                                        .checkexistsItem(
                                                            categoryList!
                                                                .productslists[
                                                                    index]
                                                                .id
                                                                .toString())
                                                        .then((value) {
                                                      if (value.length > 0) {
                                                        var item = value.first;
                                                        OrderItemsModel mitem =
                                                            OrderItemsModel(
                                                          id: item['id'],
                                                          amount:
                                                              item['amount'],
                                                          category:
                                                              item['category'],
                                                          image: item['image'],
                                                          productId:
                                                              item['productId'],
                                                          productname: item[
                                                              'productname'],
                                                          tag_id:
                                                              item['tag_id'],
                                                          tag_name:
                                                              item['tag_name'],
                                                          tag_price:
                                                              item['tag_price'],
                                                          quantity: (int.parse(item[
                                                                      'quantity']) +
                                                                  1)
                                                              .toString(),
                                                        );
                                                        _db.updateCart(mitem);
                                                        _showToast(
                                                            "Cart Updated",
                                                            Icons.check,
                                                            Colors.green);
                                                      } else {
                                                        OrderItemsModel item = OrderItemsModel(
                                                            amount: categoryList!
                                                                .productslists[
                                                                    index]
                                                                .sellingPrice,
                                                            category: categoryList!
                                                                .productslists[
                                                                    index]
                                                                .category
                                                                .name,
                                                            image: categoryList!
                                                                .productslists[
                                                                    index]
                                                                .photo,
                                                            productId:
                                                                categoryList!
                                                                    .productslists[
                                                                        index]
                                                                    .id
                                                                    .toString(),
                                                            productname:
                                                                categoryList!
                                                                    .productslists[
                                                                        index]
                                                                    .name,
                                                            quantity: categoryList!
                                                                .productslists[
                                                                    index]
                                                                .quantity
                                                                .toString(),
                                                            tag_id: "none",
                                                            tag_name: "none",
                                                            tag_price: "none");
                                                        _db
                                                            .newCart(item)
                                                            .then((value) {
                                                          _showToast(
                                                              "Item Added to Cart",
                                                              Icons.check,
                                                              Colors.green);
                                                          ordersList.clear();
                                                          _db
                                                              .getAllCarts()
                                                              .then((value2) {
                                                            setState(() {
                                                              ordersList.addAll(
                                                                  value2);
                                                              widget
                                                                  .fetch(true);
                                                            });
                                                          });
                                                        });
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text(
                                                      cartproducts.contains(
                                                              categoryList!
                                                                      .productslists[
                                                                  index])
                                                          ? "Item Added"
                                                          : " Add to Cart",
                                                      style: GoogleFonts.montserrat(
                                                          fontSize: 14,
                                                          color: cartproducts.contains(
                                                                  categoryList!
                                                                          .productslists[
                                                                      index])
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                      : loading
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
                                categoryList != null
                                    ? "No ${categoryList!.name} Available"
                                    : "No Products Available",
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                ))
              ])
        ],
      ),
    );
  }
}
