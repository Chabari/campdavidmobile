import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/helpers/unitlist.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';

class ProductDetails extends StatefulWidget {
  ProductList productList;

  ProductDetails({required this.productList});
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List<UnitList> unitLists = [];
  List<CategoryList> categorylists = [];
  CategoryList? categoryList;
  bool loading = false;
  final DBHelper _db = DBHelper();
  List<ProductList> cartproducts = [];
  List<OrderItemsModel> ordersList = [];
  late FToast fToast;
  TagElement? selectedtag;
  String text = "Checkout Ksh ";
  double total = 0;
  bool isLogged = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);

    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        setState(() {
          isLogged = true;
        });
      }
    });

    total = double.parse(widget.productList.sellingPrice);
    getUnits().then((value) {
      setState(() {
        unitLists.addAll(value);
      });
    });
    getcategoryList().then((value) {
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
    });
    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
      });
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
      title: "Confirmation",
      desc: "Please make sure you login to proceed with this action",
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
            "LOGIN",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(from: "check"),
                ));
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
        )
      ],
    ).show();
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
                          padding:
                              const EdgeInsets.all(8.0).copyWith(bottom: 0),
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
                              InkWell(
                                onTap: () {
                                  if (widget.productList.tags.length > 0) {
                                    if (selectedtag == null) {
                                      _db
                                          .checkexistsItem(
                                              widget.productList.id.toString())
                                          .then((value) {
                                        if (value.length > 0) {
                                          Fluttertoast.showToast(
                                              msg: "Cart Updated",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          OrderItemsModel item =
                                              OrderItemsModel(
                                            amount:
                                                widget.productList.sellingPrice,
                                            category: widget
                                                .productList.category.name,
                                            image: widget.productList.photo,
                                            productId: widget.productList.id
                                                .toString(),
                                            tag_id: "none",
                                            tag_name: "none",
                                            tag_price: "none",
                                            productname:
                                                widget.productList.name,
                                            quantity: widget
                                                .productList.quantity
                                                .toString(),
                                          );
                                          _db.newCart(item).then((value) {
                                            Fluttertoast.showToast(
                                                msg: "Item Added to Cart",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            ordersList.clear();
                                            _db.getAllCarts().then((value2) {
                                              setState(() {
                                                ordersList.addAll(value2);
                                              });
                                            });
                                          });
                                        }
                                      });
                                    } else {
                                      _db
                                          .checkexistsItem(
                                              "${widget.productList.id}.${selectedtag!.id}")
                                          .then((value) {
                                        if (value.length > 0) {
                                          Fluttertoast.showToast(
                                              msg: "Cart Updated",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          OrderItemsModel item =
                                              OrderItemsModel(
                                            amount:
                                                widget.productList.sellingPrice,
                                            category: widget
                                                .productList.category.name,
                                            image: widget.productList.photo,
                                            productId:
                                                "${widget.productList.id}.${selectedtag!.id}",
                                            tag_id: selectedtag!.id.toString(),
                                            tag_name: selectedtag!.tag.name,
                                            tag_price: selectedtag!.price,
                                            productname:
                                                widget.productList.name,
                                            quantity: widget
                                                .productList.quantity
                                                .toString(),
                                          );
                                          _db.newCart(item).then((value) {
                                            Fluttertoast.showToast(
                                                msg: "Item Added to Cart",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            ordersList.clear();
                                            _db.getAllCarts().then((value2) {
                                              setState(() {
                                                ordersList.addAll(value2);
                                              });
                                            });
                                          });
                                        }
                                      });
                                    }
                                  } else {
                                    _db
                                        .checkexistsItem(
                                            widget.productList.id.toString())
                                        .then((value) {
                                      if (value.length > 0) {
                                        var item = value.first;
                                        OrderItemsModel mitem = OrderItemsModel(
                                          id: item['id'],
                                          amount: item['amount'],
                                          category: item['category'],
                                          image: item['image'],
                                          productId: item['productId'],
                                          productname: item['productname'],
                                          tag_id: "none",
                                          tag_name: "none",
                                          tag_price: "none",
                                          quantity:
                                              (int.parse(item['quantity']) + 1)
                                                  .toString(),
                                        );
                                        _db.updateCart(mitem);
                                        Fluttertoast.showToast(
                                            msg: "Cart Update",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      } else {
                                        OrderItemsModel item = OrderItemsModel(
                                          amount:
                                              widget.productList.sellingPrice,
                                          category:
                                              widget.productList.category.name,
                                          image: widget.productList.photo,
                                          productId:
                                              widget.productList.id.toString(),
                                          tag_id: "none",
                                          tag_name: "none",
                                          tag_price: "none",
                                          productname: widget.productList.name,
                                          quantity: widget.productList.quantity
                                              .toString(),
                                        );
                                        _db.newCart(item).then((value) {
                                          Fluttertoast.showToast(
                                              msg: "Item Added to Cart",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                          ordersList.clear();
                                          _db.getAllCarts().then((value2) {
                                            setState(() {
                                              ordersList.addAll(value2);
                                            });
                                          });
                                        });
                                      }
                                    });
                                    setState(() {
                                      cartproducts.add(widget.productList);
                                    });
                                  }
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0)
                                        .copyWith(bottom: 0),
                                    child: Icon(Icons.shopping_cart)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            widget.productList.category.name,
                            style: GoogleFonts.montserrat(color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                " Ksh",
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.grey),
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
                            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
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
                                    itemCount: widget.productList.tags.length,
                                    itemBuilder: (context, index) => Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                              color: widget.productList
                                                      .tags[index].isselected
                                                  ? Colors.grey
                                                  : primaryColor)),
                                      color: widget.productList.tags[index]
                                              .isselected
                                          ? Colors.grey
                                          : Colors.white,
                                      child: InkWell(
                                        onTap: () {
                                          widget.productList.tags.forEach(
                                            (element) {
                                              if (element.id !=
                                                      widget.productList
                                                          .tags[index].id &&
                                                  element.isselected) {
                                                setState(() {
                                                  element.isselected = false;
                                                });
                                              }
                                            },
                                          );
                                          setState(() {
                                            widget.productList.tags[index]
                                                    .isselected =
                                                !widget.productList.tags[index]
                                                    .isselected;
                                          });
                                          if (widget.productList.tags[index]
                                              .isselected) {
                                            total = double.parse(widget
                                                .productList.tags[index].price);
                                            setState(() {
                                              selectedtag = widget
                                                  .productList.tags[index];
                                            });
                                          } else {
                                            total = double.parse(widget
                                                .productList.sellingPrice);
                                            setState(() {
                                              selectedtag = null;
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "${widget.productList.tags[index].tag.name} - Ksh ${widget.productList.tags[index].price}",
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold),
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
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          padding: const EdgeInsets.all(10),
                          width: getWidth(context),
                          height: 48,
                          decoration: const BoxDecoration(
                              color: backGround,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categorylists.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(0.0)
                                        .copyWith(right: 10),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (categorylists[index].selected ==
                                              false)
                                            const SizedBox(
                                              height: 4,
                                            ),
                                          Text(
                                            categorylists[index].name,
                                            style: GoogleFonts.montserrat(
                                                color: categorylists[index]
                                                        .selected
                                                    ? primaryColor
                                                    : Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (categorylists[index].selected)
                                            Container(
                                              height: 10,
                                              width: 10,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: primaryColor),
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

                        categoryList != null &&
                                categoryList!.productslists.length > 0
                            ? ListView.builder(
                                itemCount: categoryList!.productslists.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                                                    productList: categoryList!
                                                        .productslists[index]),
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
                                                      categoryList!
                                                          .productslists[index]
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
                                                      categoryList!
                                                          .productslists[index]
                                                          .name,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize: 18,
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
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    categoryList!
                                                        .productslists[index]
                                                        .category
                                                        .name,
                                                    style:
                                                        GoogleFonts.montserrat(
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                  ),
                                                  Text(
                                                    categoryList!
                                                        .productslists[index]
                                                        .sellingPrice,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 18,
                                                            color: primaryColor,
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
                            : loading
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
                                      categoryList != null
                                          ? "No ${categoryList!.name} Available"
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
                          if (widget.productList.tags.length > 0) {
                            if (selectedtag == null) {
                              _db
                                  .checkexistsItem(
                                      widget.productList.id.toString())
                                  .then((value) {
                                if (value.length > 0) {
                                  if (isLogged) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckOutPage(),
                                        ));
                                  } else {
                                    _onAlertButtonsPressed(context);
                                  }
                                } else {
                                  OrderItemsModel item = OrderItemsModel(
                                    amount: widget.productList.sellingPrice,
                                    category: widget.productList.category.name,
                                    image: widget.productList.photo,
                                    productId: widget.productList.id.toString(),
                                    tag_id: "none",
                                    tag_name: "none",
                                    tag_price: "none",
                                    productname: widget.productList.name,
                                    quantity:
                                        widget.productList.quantity.toString(),
                                  );
                                  _db.newCart(item).then((value) {
                                    if (isLogged) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CheckOutPage(),
                                          ));
                                    } else {
                                      _onAlertButtonsPressed(context);
                                    }
                                  });
                                }
                              });
                            } else {
                              _db
                                  .checkexistsItem(
                                      "${widget.productList.id}.${selectedtag!.id}")
                                  .then((value) {
                                if (value.length > 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckOutPage(),
                                      ));
                                } else {
                                  OrderItemsModel item = OrderItemsModel(
                                    amount: widget.productList.sellingPrice,
                                    category: widget.productList.category.name,
                                    image: widget.productList.photo,
                                    productId:
                                        "${widget.productList.id}.${selectedtag!.id}",
                                    tag_id: selectedtag!.id.toString(),
                                    tag_name: selectedtag!.tag.name,
                                    tag_price: selectedtag!.price,
                                    productname: widget.productList.name,
                                    quantity:
                                        widget.productList.quantity.toString(),
                                  );
                                  _db.newCart(item).then((value) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckOutPage(),
                                        ));
                                  });
                                }
                              });
                            }
                          } else {
                            _db
                                .checkexistsItem(
                                    widget.productList.id.toString())
                                .then((value) {
                              if (value.length > 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckOutPage(),
                                    ));
                              } else {
                                OrderItemsModel item = OrderItemsModel(
                                  amount: widget.productList.sellingPrice,
                                  category: widget.productList.category.name,
                                  image: widget.productList.photo,
                                  productId: widget.productList.id.toString(),
                                  tag_id: "none",
                                  tag_name: "none",
                                  tag_price: "none",
                                  productname: widget.productList.name,
                                  quantity:
                                      widget.productList.quantity.toString(),
                                );
                                _db.newCart(item).then((value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckOutPage(),
                                      ));
                                });
                              }
                            });
                            setState(() {
                              cartproducts.add(widget.productList);
                            });
                          }
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(8.0).copyWith(bottom: 0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: primaryColor,
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "$text ${total.toStringAsFixed(0)}",
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
    );
  }
}
