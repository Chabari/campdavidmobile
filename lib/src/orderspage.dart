import 'dart:async';
import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/orderlist.dart';
import 'package:campdavid/src/orderdetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
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
  final _phoneController = TextEditingController();
  final DBHelper _db = DBHelper();
  final ScrollController _controller = ScrollController();
  double scrollto = 0.0;
  String selectedDate = DateTime.now().toIso8601String();
  late FToast fToast;
  String token = "";
  double total = 0;
  bool loading = true;

  late ArsProgressDialog progressDialog;
  List<String> dates = [];

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
          token = value.getString('token')!;
          if (mounted) {
          fetchdates().then((value) {
            if (mounted) {
              setState(() {
                dates = value;
                selectedDate = dates.last;
                scrollto += dates.length * 58;
              });
              fetchorders().then((value) {
                if (mounted) {
                  setState(() {
                    loading = false;
                    ordersList = value;
                    getsummary();
                    filterorders();
                  });
                }
              });
            }
            Future.delayed(const Duration(seconds: 1)).then((value) {
              if (_controller.hasClients) {
                _controller.animateTo(
                  scrollto,
                  duration: const Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn,
                );
              }
            });
          });
        }
          
        });
      }
    });

    

    Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (mounted) {
        fetchorders().then((value) {
          if (mounted) {
            setState(() {
              ordersList = value;
              loading = false;
              getsummary();
              filterorders();
            });
          }
        });
      }
    });
  }

  Future<List<String>> fetchdates() async {
    final uri = Uri.parse("${mainUrl}get-dates");
    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    return List.from(json.decode(res.body) as List);
  }

  Future<List<OrderList>> fetchorders() async {
    var data = {
      'date': selectedDate,
    };
    var body = json.encode(data);
    final uri = Uri.parse("${mainUrl}user-orders");
    final res = await http.post(uri,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);
    print(res.body);
    return orderListFromJson(res.body);
  }

  // void gettotals() {
  //   total = 0;
  //   delivered = 0;
  //   pending = 0;
  //   ordersList.forEach((element) {
  //     if (element.status == "Delivered") {
  //       setState(() {
  //         delivered++;
  //       });
  //     } else {
  //       setState(() {
  //         pending++;
  //       });
  //     }
  //     setState(() {
  //       total += double.parse(element.order_amount);
  //     });
  //   });
  // }

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

  void getsummary() async {
    var data = {'date': selectedDate, 'from': 'cus'};
    var body = json.encode(data);
    final uri = Uri.parse("${mainUrl}getTodaySummary");
    final res = await http.post(uri,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);
    Map<String, dynamic> json1 = json.decode(res.body);
    if (mounted) {
      setState(() {
        total = double.parse(json1['order'].toString());
      });
    }
  }

  void initiateMpesa(order_id) async {
    progressDialog.show();
    Map data = {
      'order_id': order_id.toString(),
      'phone': _phoneController.text,
    };
    var body = json.encode(data);

    var response = await http.post(Uri.parse('${mainUrl}initiate_mpesa'),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: body);

    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      progressDialog.dismiss();
      if (json1['success'] == "1") {
        Fluttertoast.showToast(
            msg: json1['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: json1['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      progressDialog.dismiss();
      Fluttertoast.showToast(
          msg: json1['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _scrollLeft() {
    setState(() {
      scrollto -= 58.0;
    });
    _controller.animateTo(scrollto,
        duration: const Duration(microseconds: 300), curve: Curves.easeIn);
  }

  void _scrollRight() {
    setState(() {
      scrollto += 58.0;
    });
    _controller.animateTo(scrollto,
        duration: const Duration(microseconds: 300), curve: Curves.easeIn);
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
            // Row(
            //   children: [
            //     Expanded(
            //         child: Column(
            //       children: [
            //         Text(
            //           ordersList.length.toString(),
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white, fontSize: 25),
            //         ),
            //         Text(
            //           "Orders Count",
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white, fontSize: 12),
            //         ),
            //       ],
            //     )),
            //     Expanded(
            //         child: Column(
            //       children: [
            //         Text(
            //           pending.toString(),
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white, fontSize: 25),
            //         ),
            //         Text(
            //           "Pending Orders",
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white, fontSize: 12),
            //         ),
            //       ],
            //     )),
            //     Expanded(
            //         child: Column(
            //       children: [
            //         Text(
            //           delivered.toString(),
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //               fontSize: 25),
            //         ),
            //         Text(
            //           "Delivered Orders",
            //           style: GoogleFonts.montserrat(
            //               color: Colors.white, fontSize: 12),
            //         ),
            //       ],
            //     ))
            //   ],
            // ),

            Container(
              width: getWidth(context),
              height: 45,
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  InkWell(
                      onTap: () => _scrollLeft(),
                      child: const Icon(
                        Icons.arrow_left_outlined,
                        size: 35,
                      )),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: dates.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          setState(() {
                            selectedDate = dates[index];
                            filteredordersList.clear();
                            loading = true;
                          });
                          fetchorders().then((value) {
                            getsummary();
                            if (mounted) {
                              setState(() {
                                loading = false;
                                ordersList = value;
                                filterorders();
                              });
                            }
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selectedDate == dates[index]
                              ? Colors.white
                              : primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              getdatestringformat(dates[index]),
                              style: GoogleFonts.montserrat(
                                color: selectedDate == dates[index]
                                    ? primaryColor
                                    : Colors.white,
                              ),
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () => _scrollRight(),
                      child: const Icon(Icons.arrow_right_outlined, size: 35)),
                ],
              ),
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
                    filteredordersList.length > 0
                        ? ListView.builder(
                            itemCount: filteredordersList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 3,
                              margin: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetails(
                                          orderlist: filteredordersList[index]),
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  ),
                                                ),
                                                Text(
                                                  "#${filteredordersList[index].orderNumber}",
                                                  style: GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  "Delivery Code",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  filteredordersList[index]
                                                      .customer_code,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 20,
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                  filteredordersList[index]
                                                      .createdAt),
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            "Ksh ${filteredordersList[index].order_amount}",
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Delivery Status",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 14),
                                              ),

                                              Text(
                                                filteredordersList[index].status,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: filteredordersList[index]
                                                                .status ==
                                                            "Delivered"
                                                        ? Colors.green
                                                        : Colors.grey),
                                              ),
                                            ],
                                          )),
                                          if(filteredordersList[index].pickup_time != "none")
                                            Expanded(child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Pickup Time",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 14),
                                                ),

                                                Text(
                                                  filteredordersList[index].pickup_time,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 16,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ))
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
                                                                filteredordersList[
                                                                    index]),
                                                  )),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  // side: const BorderSide(
                                                  //     color: Colors.black)
                                                ),
                                                elevation: 3,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Center(
                                                    child: Text(
                                                      "View Details",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _phoneController.text =
                                                      filteredordersList[index]
                                                          .customer_phone;
                                                });
                                                if (filteredordersList[index]
                                                        .isPaid ==
                                                    0) {
                                                  Alert(
                                                      context: context,
                                                      title:
                                                          "Mpesa Confirmation",
                                                      content: Column(
                                                        children: [
                                                          Text(
                                                            "Please confirm the number to send mpesa stk push notification",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          TextField(
                                                            controller:
                                                                _phoneController,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    color: Colors
                                                                        .black),
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Phone',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      buttons: [
                                                        DialogButton(
                                                          color: primaryColor,
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            initiateMpesa(
                                                                filteredordersList[
                                                                        index]
                                                                    .id);
                                                          },
                                                          child: Text(
                                                            "SUBMIT",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                        )
                                                      ]).show();
                                                }
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: filteredordersList[index]
                                                            .isPaid ==
                                                        1
                                                    ? Colors.green
                                                    : primaryColor,
                                                elevation: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Center(
                                                    child: Text(
                                                      filteredordersList[index]
                                                                  .isPaid ==
                                                              1
                                                          ? "Paid"
                                                          : "Make Payment",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
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
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "No Orders Available",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey,
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
