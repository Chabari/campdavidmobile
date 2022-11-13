import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/cartmodel.dart';
import 'package:campdavid/helpers/categorylist.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/productlists.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:campdavid/src/productspage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../helpers/databaseHelper.dart';

class Home extends StatefulWidget {
  Function(int) screen;
  Function(bool) fetch;
  Home({required this.screen, required this.fetch});
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryList> categorylists = [];
  List<ProductList> productslists = [];
  List<ProductList> cartproducts = [];
  List<OrderItemsModel> ordersList = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  String selectedprice = "";
  TagElement? selectedtag;
  late ArsProgressDialog progressDialog;
  bool isItemSelected = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: const Color(0x33000000),
        animationDuration: const Duration(milliseconds: 500));
    getcategoryList().then((value) {
      setState(() {
        categorylists = value;
      });
    });
    getTopProducts().then((value) {
      setState(() {
        productslists = value;
      });
    });

    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
      });
    });
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

  Future<List<ProductList>> getTopProducts() async {
    var url = Uri.parse('${mainUrl}top-products');
    var response = await http.get(url);
    if (response.body.isEmpty) {
      return [];
    }
    return productListFromJson(response.body);
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
          categorylists.length > 0
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: categorylists.length,
                  itemBuilder: (BuildContext context, int index) => InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductsPage(categoryList: categorylists[index]),
                        )),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: Image.network(imageUrl +
                                  getimage(categorylists[index].photo)),
                            ),
                            Text(
                              categorylists[index].name,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
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
                if (categorylists.length > 0)
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductsPage(categoryList: categorylists.first),
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
          productslists.length > 0
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: productslists.length,
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
                                  productList: productslists[index]),
                            ));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(imageUrl +
                                        getimage(productslists[index].photo)))),
                            height: 98,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              productslists[index].category.name,
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              productslists[index].name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Row(
                              children: [
                                Text(
                                  " Ksh",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  productslists[index].sellingPrice,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.all(8.0).copyWith(bottom: 0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: cartproducts
                                            .contains(productslists[index])
                                        ? primaryColor
                                        : Colors.black),
                              ),
                              color: cartproducts.contains(productslists[index])
                                  ? primaryColor
                                  : Colors.white,
                              elevation: 3,
                              child: InkWell(
                                onTap: () {
                                  if (productslists[index].tags.length > 0) {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32),
                                              topRight: Radius.circular(32))),
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setModalState) {
                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(32),
                                                  topRight:
                                                      Radius.circular(32)),
                                            ),
                                            height: 350,
                                            child: Stack(
                                              children: [
                                                SingleChildScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Select Item',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            const BoxDecoration(
                                                                // border: Border.fromBorderSide(top)
                                                                ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            productslists[index]
                                                                .tags
                                                                .forEach(
                                                                    (element) {
                                                              setModalState(() {
                                                                element.isselected =
                                                                    false;
                                                              });
                                                            });
                                                            setModalState(() {
                                                              isItemSelected =
                                                                  true;
                                                              selectedtag =
                                                                  null;
                                                              selectedprice =
                                                                  productslists[
                                                                          index]
                                                                      .sellingPrice;
                                                            });
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      isItemSelected
                                                                          ? Icons
                                                                              .radio_button_checked
                                                                          : Icons
                                                                              .radio_button_off,
                                                                      size: 30,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Text(
                                                                      "1 ${productslists[index].unit.name}",
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            18,
                                                                      ),
                                                                    )),
                                                                    Text(
                                                                        " Ksh ${productslists[index].sellingPrice}",
                                                                        style: GoogleFonts.cabin(
                                                                            fontSize:
                                                                                18))
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListView.builder(
                                                        itemCount:
                                                            productslists[index]
                                                                .tags
                                                                .length,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8,
                                                                bottom: 30),
                                                        itemBuilder:
                                                            (context, ind) =>
                                                                Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              const BoxDecoration(
                                                                  // border: Border.fromBorderSide(top)
                                                                  ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              productslists[
                                                                      index]
                                                                  .tags
                                                                  .forEach(
                                                                      (element) {
                                                                setModalState(
                                                                    () {
                                                                  element.isselected =
                                                                      false;
                                                                });
                                                              });
                                                              setModalState(() {
                                                                isItemSelected =
                                                                    false;
                                                                productslists[
                                                                        index]
                                                                    .tags[ind]
                                                                    .isselected = true;
                                                                selectedtag =
                                                                    productslists[
                                                                            index]
                                                                        .tags[ind];
                                                                selectedprice =
                                                                    productslists[
                                                                            index]
                                                                        .tags[
                                                                            ind]
                                                                        .price;
                                                              });
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        productslists[index].tags[ind].isselected
                                                                            ? Icons.radio_button_checked
                                                                            : Icons.radio_button_off,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Expanded(
                                                                          child:
                                                                              Text(
                                                                        productslists[index]
                                                                            .tags[ind]
                                                                            .tag
                                                                            .name,
                                                                        style: GoogleFonts
                                                                            .montserrat(
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                      )),
                                                                      Text(
                                                                          " Ksh ${productslists[index].tags[ind].price}",
                                                                          style:
                                                                              GoogleFonts.cabin(fontSize: 18))
                                                                    ],
                                                                  ),
                                                                  const Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: getWidth(context),
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
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (selectedtag !=
                                                                  null) {
                                                                _db
                                                                    .checkexistsItem(
                                                                        "${productslists[index].id}.${selectedtag!.id}")
                                                                    .then(
                                                                        (value) {
                                                                  if (value
                                                                          .length >
                                                                      0) {
                                                                    var item =
                                                                        value
                                                                            .first;
                                                                    OrderItemsModel
                                                                        mitem =
                                                                        OrderItemsModel(
                                                                      id: item[
                                                                          'id'],
                                                                      amount: item[
                                                                          'amount'],
                                                                      category:
                                                                          item[
                                                                              'category'],
                                                                      image: item[
                                                                          'image'],
                                                                      productId:
                                                                          item[
                                                                              'productId'],
                                                                      productname:
                                                                          item[
                                                                              'productname'],
                                                                      tag_id: item[
                                                                          'tag_id'],
                                                                      tag_name:
                                                                          item[
                                                                              'tag_name'],
                                                                      tag_price:
                                                                          item[
                                                                              'tag_price'],
                                                                      quantity: (int.parse(item['quantity']) +
                                                                              1)
                                                                          .toString(),
                                                                    );
                                                                    _db.updateCart(
                                                                        mitem);
                                                                    Fluttertoast.showToast(
                                                                        msg:
                                                                            "Cart Updated",
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .CENTER,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .green,
                                                                        textColor:
                                                                            Colors
                                                                                .white,
                                                                        fontSize:
                                                                            16.0);
                                                                    Navigator.pop(
                                                                        context);
                                                                  } else {
                                                                    OrderItemsModel item = OrderItemsModel(
                                                                        amount: productslists[index]
                                                                            .sellingPrice,
                                                                        category: productslists[index]
                                                                            .category
                                                                            .name,
                                                                        image: productslists[index]
                                                                            .photo,
                                                                        productId:
                                                                            "${productslists[index].id}.${selectedtag!.id}",
                                                                        productname:
                                                                            productslists[index]
                                                                                .name,
                                                                        quantity: productslists[index]
                                                                            .quantity
                                                                            .toString(),
                                                                        tag_id: selectedtag!
                                                                            .id
                                                                            .toString(),
                                                                        tag_name: selectedtag!
                                                                            .tag
                                                                            .name,
                                                                        tag_price:
                                                                            selectedtag!.price);
                                                                    _db
                                                                        .newCart(
                                                                            item)
                                                                        .then(
                                                                            (value) {
                                                                      Fluttertoast.showToast(
                                                                          msg:
                                                                              "Item Added to Cart",
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .CENTER,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                      ordersList
                                                                          .clear();
                                                                      _db
                                                                          .getAllCarts()
                                                                          .then(
                                                                              (value2) {
                                                                        setState(
                                                                            () {
                                                                          ordersList
                                                                              .addAll(value2);
                                                                          widget
                                                                              .fetch(true);
                                                                        });
                                                                      });

                                                                    Navigator.pop(
                                                                        context);
                                                                    });
                                                                  }
                                                                });
                                                              } else {
                                                                if (isItemSelected) {
                                                                  setState(() {
                                                                    cartproducts.add(
                                                                        productslists[
                                                                            index]);
                                                                  });

                                                                  _db
                                                                      .checkexistsItem(productslists[
                                                                              index]
                                                                          .id
                                                                          .toString())
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                            .length >
                                                                        0) {
                                                                      var item =
                                                                          value
                                                                              .first;
                                                                      OrderItemsModel
                                                                          mitem =
                                                                          OrderItemsModel(
                                                                        id: item[
                                                                            'id'],
                                                                        amount:
                                                                            item['amount'],
                                                                        category:
                                                                            item['category'],
                                                                        image: item[
                                                                            'image'],
                                                                        productId:
                                                                            item['productId'],
                                                                        productname:
                                                                            item['productname'],
                                                                        tag_id:
                                                                            item['tag_id'],
                                                                        tag_name:
                                                                            item['tag_name'],
                                                                        tag_price:
                                                                            item['tag_price'],
                                                                        quantity:
                                                                            (int.parse(item['quantity']) + 1).toString(),
                                                                      );
                                                                      _db.updateCart(
                                                                          mitem);

                                                                      // _showToast("Cart Updated", Icons.check,
                                                                      //     Colors.green);
                                                                      Fluttertoast.showToast(
                                                                          msg:
                                                                              "Cart Updated",
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .CENTER,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    } else {
                                                                      OrderItemsModel item = OrderItemsModel(
                                                                          amount: productslists[index]
                                                                              .sellingPrice,
                                                                          category: productslists[index]
                                                                              .category
                                                                              .name,
                                                                          image: productslists[index]
                                                                              .photo,
                                                                          productId: productslists[index]
                                                                              .id
                                                                              .toString(),
                                                                          productname: productslists[index]
                                                                              .name,
                                                                          quantity: productslists[index]
                                                                              .quantity
                                                                              .toString(),
                                                                          tag_id:
                                                                              "none",
                                                                          tag_name:
                                                                              "none",
                                                                          tag_price:
                                                                              "none");
                                                                      _db
                                                                          .newCart(
                                                                              item)
                                                                          .then(
                                                                              (value) {
                                                                        // _showToast("Item Added to Cart",
                                                                        //     Icons.check, Colors.green);
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                "Item Added to Cart",
                                                                            toastLength: Toast
                                                                                .LENGTH_SHORT,
                                                                            gravity: ToastGravity
                                                                                .CENTER,
                                                                            timeInSecForIosWeb:
                                                                                1,
                                                                            backgroundColor:
                                                                                Colors.green,
                                                                            textColor: Colors.white,
                                                                            fontSize: 16.0);

                                                                        ordersList
                                                                            .clear();
                                                                        _db.getAllCarts().then(
                                                                            (value2) {
                                                                          setState(
                                                                              () {
                                                                            ordersList.addAll(value2);
                                                                            widget.fetch(true);
                                                                          });
                                                                        });
                                                                      });
                                                                    }
                                                                  });
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "Select Item to add to cart",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      gravity: ToastGravity
                                                                          .CENTER,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          16.0);
                                                                }
                                                              }
                                                            },
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              color:
                                                                  primaryColor,
                                                              elevation: 3,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Center(
                                                                  child: Text(
                                                                    " Add Cart",
                                                                    style: GoogleFonts.montserrat(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
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
                                      cartproducts.add(productslists[index]);
                                    });

                                    _db
                                        .checkexistsItem(
                                            productslists[index].id.toString())
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
                                          tag_id: item['tag_id'],
                                          tag_name: item['tag_name'],
                                          tag_price: item['tag_price'],
                                          quantity:
                                              (int.parse(item['quantity']) + 1)
                                                  .toString(),
                                        );
                                        _db.updateCart(mitem);

                                        // _showToast("Cart Updated", Icons.check,
                                        //     Colors.green);
                                        Fluttertoast.showToast(
                                            msg: "Cart Updated",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      } else {
                                        OrderItemsModel item = OrderItemsModel(
                                            amount: productslists[index]
                                                .sellingPrice,
                                            category: productslists[index]
                                                .category
                                                .name,
                                            image: productslists[index].photo,
                                            productId: productslists[index]
                                                .id
                                                .toString(),
                                            productname:
                                                productslists[index].name,
                                            quantity: productslists[index]
                                                .quantity
                                                .toString(),
                                            tag_id: "none",
                                            tag_name: "none",
                                            tag_price: "none");
                                        _db.newCart(item).then((value) {
                                          // _showToast("Item Added to Cart",
                                          //     Icons.check, Colors.green);
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
                                              widget.fetch(true);
                                            });
                                          });
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      cartproducts
                                              .contains(productslists[index])
                                          ? "Item Added"
                                          : " Add to Cart",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: cartproducts.contains(
                                                  productslists[index])
                                              ? Colors.white
                                              : Colors.black,
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
    );
  }
}
