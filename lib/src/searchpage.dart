import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';
import '../helpers/productlists.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchEditingController = TextEditingController();
  List<ProductList> productslists = [];
  bool istyping = false;
  String text = "";
  String searchText = "";
  List<ProductList> cartproducts = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  List<OrderItemsModel> ordersList = [];
  TagElement? selectedtag;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
      });
    });
  }

  Future<List<ProductList>> getProducts() async {
    var url = Uri.parse('${mainUrl}search-products');
    Map<String, dynamic> data = {'query': _searchEditingController.text};
    var response = await http.post(url,
        headers: {
          'Accept': 'application/json',
          'Access-Control_Allow_Origin': '*'
        },
        body: data);
    return productListFromJson(response.body);
  }

  void updateSearchQuery(String newQuery) {
    productslists.clear();
    setState(() {
      istyping = true;
      searchText = newQuery;
    });
    if (newQuery.length > 0) {
      getProducts().then((value) {
        setState(() {
          productslists = value;
          istyping = false;
        });
      });
    } else {
      setState(() {
        text = "Search for products here";
      });
    }
    setState(() {});
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
                  updateSearchQuery(value);
                  if (value.isEmpty) {
                    setState(() {
                      istyping = false;
                    });
                  }
                },
                controller: _searchEditingController,
                autofocus: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                      borderRadius: BorderRadius.all(Radius.circular(32))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(32))),
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
                      setState(() {
                        searchText = '';
                        _searchEditingController.text = '';
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      color: searchText.isNotEmpty
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
            productslists.length > 0
                ? Expanded(
                  child: ListView.builder(
                      itemCount: productslists.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.all(6),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(
                                      productList: productslists[index],
                                    ),
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
                                              productslists[index].photo))),
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              productslists[index].name,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (productslists[index]
                                                      .tags
                                                      .length >
                                                  0) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          32),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          32))),
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setModalState) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
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
                                                                    height: 20,
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      'Select Item',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ListView
                                                                      .builder(
                                                                    itemCount:
                                                                        productslists[
                                                                                index]
                                                                            .tags
                                                                            .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 8,
                                                                        bottom:
                                                                            30),
                                                                    itemBuilder: (context,
                                                                            ind) =>
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(6),
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                              // border: Border.fromBorderSide(top)
                                                                              ),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          productslists[index]
                                                                              .tags
                                                                              .forEach((element) {
                                                                            setModalState(
                                                                                () {
                                                                              element.isselected =
                                                                                  false;
                                                                            });
                                                                          });
                                                                          setModalState(
                                                                              () {
                                                                            productslists[index]
                                                                                .tags[ind]
                                                                                .isselected = true;
                                                                            selectedtag =
                                                                                productslists[index].tags[ind];
                                                                          });
                                                                        },
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    child: Icon(
                                                                                      productslists[index].tags[ind].isselected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                                                      size: 30,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 4,
                                                                                  ),
                                                                                  Expanded(
                                                                                      child: Container(
                                                                                    child: Text(
                                                                                      productslists[index].tags[ind].tag.name,
                                                                                      style: GoogleFonts.montserrat(
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    ),
                                                                                  )),
                                                                                  Text(" Ksh " + productslists[index].tags[ind].price, style: GoogleFonts.cabin(fontSize: 18))
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
                                                                width: getWidth(
                                                                    context),
                                                                child: Row(
                                                                  children: [
                                                                    
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (selectedtag !=
                                                                              null) {
                                                                            _db.checkexistsItem("${productslists[index].id}.${selectedtag!.id}").then(
                                                                                (value) {
                                                                              if (value.length >
                                                                                  0) {
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
                                                                                Fluttertoast.showToast(
                                                                                        msg: "Cart Updated",
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        timeInSecForIosWeb: 1,
                                                                                        backgroundColor: Colors.green,
                                                                                        textColor: Colors.white,
                                                                                        fontSize: 16.0
                                                                                    );
                                                                                // _showToast("Cart Updated", Icons.check, Colors.green);
                                                                              } else {
                                                                                OrderItemsModel item = OrderItemsModel(amount: productslists[index].sellingPrice, category: productslists[index].category.name, image: productslists[index].photo, productId: "${productslists[index].id}.${selectedtag!.id}", productname: productslists[index].name, quantity: productslists[index].quantity.toString(), tag_id: selectedtag!.id.toString(), tag_name: selectedtag!.tag.name, tag_price: selectedtag!.price);
                                                                                _db.newCart(item).then((value) {
                                                                                  Fluttertoast.showToast(
                                                                                        msg: "Item Added to Cart",
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        timeInSecForIosWeb: 1,
                                                                                        backgroundColor: Colors.green,
                                                                                        textColor: Colors.white,
                                                                                        fontSize: 16.0
                                                                                    );
                                                                                  // _showToast("Item Added to Cart", Icons.check, Colors.green);
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
                                                                            Fluttertoast.showToast(
                                                                                        msg: "Select Item to add to cart",
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        timeInSecForIosWeb: 1,
                                                                                        backgroundColor: Colors.red,
                                                                                        textColor: Colors.white,
                                                                                        fontSize: 16.0
                                                                                    );
                
                                                                            // _showToast(
                                                                            //     "Select Item to add to cart",
                                                                            //     Icons.cancel,
                                                                            //     Colors.red);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          color:
                                                                              primaryColor,
                                                                          elevation:
                                                                              3,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Center(
                                                                              child:
                                                                                  Text(
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
                                                  cartproducts
                                                      .add(productslists[index]);
                                                });
                
                                                _db
                                                    .checkexistsItem(
                                                        productslists[index]
                                                            .id
                                                            .toString())
                                                    .then((value) {
                                                  if (value.length > 0) {
                                                    var item = value.first;
                                                    OrderItemsModel mitem =
                                                        OrderItemsModel(
                                                      id: item['id'],
                                                      amount: item['amount'],
                                                      category: item['category'],
                                                      image: item['image'],
                                                      productId:
                                                          item['productId'],
                                                      tag_id: item['tag_id'],
                                                      tag_name: item['tag_name'],
                                                      tag_price:
                                                          item['tag_price'],
                                                      productname:
                                                          item['productname'],
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
                                                    OrderItemsModel item =
                                                        OrderItemsModel(
                                                      amount: productslists[index]
                                                          .sellingPrice,
                                                      category:
                                                          productslists[index]
                                                              .category
                                                              .name,
                                                      image: productslists[index]
                                                          .photo,
                                                      productId:
                                                          productslists[index]
                                                              .id
                                                              .toString(),
                                                      productname:
                                                          productslists[index]
                                                              .name,
                                                      tag_id: "none",
                                                      tag_name: "none",
                                                      tag_price: "none",
                                                      quantity:
                                                          productslists[index]
                                                              .quantity
                                                              .toString(),
                                                    );
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
                                                          ordersList
                                                              .addAll(value2);
                                                        });
                                                      });
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                            child: Card(
                                              child: Icon(
                                                Icons.shopping_cart,
                                                color: cartproducts.contains(
                                                        productslists[index])
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
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            productslists[index].category.name,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
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
                                  ],
                                ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                )
                : istyping
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
    );
  }
}
