import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';

class CartPage extends StatefulWidget {
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<OrderItemsModel> ordersList = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  late ArsProgressDialog progressDialog;
  String text = "Your Cart is Empty";
  double total = 0;
  bool isLogged = false;
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

    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        setState(() {
          isLogged = true;
        });
      }
    });

    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
        getTotal();
      });
    });
  }

  void getTotal() {
    total = 0;
    ordersList.forEach((element) {
      if (element.tag_name != 'none') {
        total +=
            (double.parse(element.tag_price) * double.parse(element.quantity));
      } else {
        total +=
            (double.parse(element.amount) * double.parse(element.quantity));
      }
    });
    setState(() {
      text = "Proceed to checkout Ksh $total ";
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: getHeight(context),
      width: getWidth(context),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: ordersList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(6),
                    elevation: 3,
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      imageUrl + ordersList[index].image))),
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
                                      ordersList[index].tag_name != "none"
                                          ? ordersList[index].productname
                                          : ordersList[index].productname,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _db
                                          .deleteCart(
                                              ordersList[index].productId)
                                          .then((value) {
                                        ordersList.clear();
                                        _db.getAllCarts().then((value2) {
                                          setState(() {
                                            ordersList.addAll(value2);
                                          });
                                          getTotal();
                                        });
                                      });
                                    },
                                    child: const Card(
                                      child: Icon(
                                        Icons.delete_forever_outlined,
                                        color: primaryColor,
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
                                  if (ordersList[index].tag_name != "none")
                                    Text(
                                      "${ordersList[index].tag_name} @ Ksh ",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  else
                                    Text(
                                      " Ksh",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  if (ordersList[index].tag_name != "none")
                                    Text(
                                      ordersList[index].tag_price,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  else
                                    Text(
                                      ordersList[index].amount,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (int.parse(ordersList[index].quantity) >
                                        1) {
                                      _db
                                          .checkexistsItem(
                                              ordersList[index].productId)
                                          .then((value) {
                                        if (value.length > 0) {
                                          var item = value.first;
                                          OrderItemsModel mitem =
                                              OrderItemsModel(
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
                                                (int.parse(item['quantity']) -
                                                        1)
                                                    .toString(),
                                          );
                                          _db.updateCart(mitem);

                                          ordersList.clear();
                                          _db.getAllCarts().then((value2) {
                                            setState(() {
                                              ordersList.addAll(value2);
                                            });
                                            getTotal();
                                          });
                                        }
                                      });
                                    } else {
                                      _db
                                          .deleteCart(
                                              ordersList[index].productId)
                                          .then((value) {
                                        ordersList.clear();
                                        _db.getAllCarts().then((value2) {
                                          setState(() {
                                            ordersList.addAll(value2);
                                          });
                                          getTotal();
                                        });
                                      });
                                    }
                                  },
                                  child: const Card(
                                    child: Icon(Icons.remove_circle_outline),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  ordersList[index].quantity,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                InkWell(
                                  onTap: () {
                                    _db
                                        .checkexistsItem(
                                            ordersList[index].productId)
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
                                        ordersList.clear();
                                        _db.getAllCarts().then((value2) {
                                          setState(() {
                                            ordersList.addAll(value2);
                                          });

                                          getTotal();
                                        });
                                      }
                                    });
                                  },
                                  child: const Card(
                                    child: Icon(Icons.add_circle_outline_sharp),
                                  ),
                                )
                              ],
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 150,
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: ClipPath(
              clipper: MovieTicketBothSidesClipper(),
              child: Container(
                height: 100,
                color: Colors.grey.shade300,
                child: Center(
                  child: SizedBox(
                    width: getWidth(context),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: primaryColor,
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          if (isLogged) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckOutPage(),
                              ));
                          } else {
                            _onAlertButtonsPressed(context);
                          }
                          
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                text,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
