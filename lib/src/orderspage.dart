import 'dart:async';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/orderlist.dart';
import 'package:campdavid/src/orderdetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/cartmodel.dart';
import '../helpers/databaseHelper.dart';

class OrdersPage extends StatefulWidget {
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int selected = 0;

  List<OrderList> ordersList = [];
  List<OrderList> filteredordersList = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  String token = "";
  double total = 0;
  int pending = 0;
  int delivered = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);

    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        setState(() {
          token = value.getString('token')!;
          fetchorders().then((value) {
            setState(() {
              ordersList = value;
              gettotals();
              filterorders();
            });
          });
        });
      }
    });

    Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (mounted) {
        
        fetchorders().then((value) {
            setState(() {
              ordersList = value;
              gettotals();
              filterorders();
            });
          });
      }
    });
  }

  Future<List<OrderList>> fetchorders() async {
    final uri = Uri.parse("${mainUrl}orders");
    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print(res.body);
    return orderListFromJson(res.body);
  }

  void gettotals() {
    total = 0;
    delivered = 0;
    pending = 0;
    ordersList.forEach((element) {
      if (element.status == "Delivered") {
        setState(() {
          delivered++;
        });
      } else {
        setState(() {
          pending++;
        });
      }
      setState(() {
        total += double.parse(element.order_amount);
      });
    });
  }

  void filterorders() {
    filteredordersList.clear();
    ordersList.forEach((element) {
      switch (selected) {
        case 0:
          if (element.status != "Delivered") {
            setState(() {
              filteredordersList.add(element);
            });
          }
          break;
        case 1:
          if (element.status == "Delivered") {
            setState(() {
              filteredordersList.add(element);
            });
          }
          break;
        case 2:
          setState(() {
            filteredordersList.add(element);
          });
          break;
      }
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: SafeArea(
            child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "My Orders",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
              child: Row(
                children: [
                  Text(
                    "Ksh",
                    style: GoogleFonts.montserrat(
                        color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    total.toString(),
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                "Order Summary",
                style:
                    GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      ordersList.length.toString(),
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 25),
                    ),
                    Text(
                      "Orders Count",
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      pending.toString(),
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 25),
                    ),
                    Text(
                      "Pending Orders",
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      delivered.toString(),
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    Text(
                      "Delivered Orders",
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
                  color: Colors.white),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selected == 0 ? Colors.grey : Colors.white,
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = 0;
                                filterorders();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.pending),
                                  Text(
                                    "Pending Orders",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selected == 1 ? Colors.grey : Colors.white,
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = 1;
                                filterorders();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.delivery_dining),
                                  Text(
                                    "Delivered",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selected == 2 ? Colors.grey : Colors.white,
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = 2;
                                filterorders();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.list),
                                  Text(
                                    "All",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (selected == 0 || selected == 2)
                      ListView.builder(
                        itemCount: ordersList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order Number",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "#${ordersList[index].orderNumber}",
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Order Code",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            ordersList[index].customer_code,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getdatedatetime(
                                            ordersList[index].createdAt),
                                        style: GoogleFonts.montserrat(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      "Ksh ${ordersList[index].order_amount}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Payment",
                                  style: GoogleFonts.montserrat(fontSize: 14),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      ordersList[index].paymentMethod,
                                      style:
                                          GoogleFonts.montserrat(fontSize: 16),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryColor),
                                        child: const Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetails(
                                                      orderlist:
                                                          ordersList[index]),
                                            )),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: const BorderSide(
                                                  color: Colors.black)),
                                          elevation: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Center(
                                              child: Text(
                                                "View Details",
                                                style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        color: primaryColor,
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Center(
                                            child: Text(
                                              ordersList[index].status,
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ))
          ],
        )),
      ),
    );
  }
}
