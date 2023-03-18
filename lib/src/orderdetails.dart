import 'dart:async';
import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/orderlist.dart';
import 'package:campdavid/src/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  OrderList orderlist;
  OrderDetails({required this.orderlist});
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String name = "";
  String phone = "";
  String paybill = "";
  String token = "";
  late FToast fToast;
  final _phoneController = TextEditingController();
  late ArsProgressDialog progressDialog;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: const Color(0x33000000),
        animationDuration: const Duration(milliseconds: 500));
    setState(() {
      _phoneController.text = widget.orderlist.customer_phone;
    });
    SharedPreferences.getInstance().then((value) {
      setState(() {
        token = value.getString('token')!;
        name = value.getString('name')!;
        phone = value.getString('phone')!;
        if (value.getString("paybill") != null) {
          paybill = value.getString("paybill")!;
        }
      });
    });
    Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (mounted) {
        fetchOrder(widget.orderlist.id.toString());
      }
    });
  }

  void fetchOrder(orderId) async {
    var data = {'order_id': orderId};
    var body = json.encode(data);
    final uri = Uri.parse("${mainUrl}getDriver");
    final res = await http.post(uri,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    if (res.statusCode == 200) {
      Map<String, dynamic> json1 = json.decode(res.body);
      setState(() {
        widget.orderlist = OrderList.fromJson(json1['order']);
      });
    } else {}
  }

  _launchWhatsapp() async {
    var whatsappAndroid = Uri();

    whatsappAndroid = Uri.parse("tel:${widget.orderlist.driver_phone}");

    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone is not installed on the device"),
        ),
      );
    }
  }

  void initiateMpesa() async {
    progressDialog.show();
    Map data = {
      'order_id': widget.orderlist.id.toString(),
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
                  "Order Details",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
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
                    if(widget.orderlist.isPickup == 0)
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 35,
                              ),
                              Text(
                                "Order Placed",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.thumb_up_alt,
                                size: 35,
                              ),
                              Text(
                                "Confirmed",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.local_shipping,
                                size: 35,
                              ),
                              Text(
                                "Shipping",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.shopping_cart_checkout_sharp,
                                size: 35,
                              ),
                              Text(
                                "Delivered",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ))
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 35,
                              ),
                              Text(
                                "Order Placed",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )),
                          // Expanded(
                          //     child: Column(
                          //   children: [
                          //     const Icon(
                          //       Icons.thumb_up_alt,
                          //       size: 35,
                          //     ),
                          //     Text(
                          //       "Confirmed",
                          //       style: GoogleFonts.montserrat(
                          //           color: Colors.grey, fontSize: 12),
                          //     ),
                          //   ],
                          // )),
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 35,
                              ),
                              Text(
                                "Order Ready",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              const Icon(
                                Icons.shopping_cart_checkout_sharp,
                                size: 35,
                              ),
                              Text(
                                "Order Picked",
                                style: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ))
                        ],
                      ),
                    
                    if(widget.orderlist.isPickup == 0)
                      Padding(
                        padding: const EdgeInsets.all(0.0)
                            .copyWith(left: 20, right: 20),
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: primaryColor),
                              padding: const EdgeInsets.all(10),
                            ),
                            Expanded(
                                child: Container(
                              color: widget.orderlist.status != "Order Placed"
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              height: 8,
                            )),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.orderlist.status != "Order Placed"
                                      ? primaryColor
                                      : Colors.grey.shade400),
                              padding: const EdgeInsets.all(10),
                            ),
                            Expanded(
                                child: Container(
                              color: widget.orderlist.status != "Order Placed" &&
                                      widget.orderlist.status != "Order Confirmed"
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              height: 8,
                            )),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      widget.orderlist.status != "Order Placed" &&
                                              widget.orderlist.status !=
                                                  "Order Confirmed" &&
                                              widget.orderlist.status !=
                                                  "Rider Confirmed"
                                          ? primaryColor
                                          : Colors.grey.shade400),
                              padding: const EdgeInsets.all(10),
                            ),
                            Expanded(
                                child: Container(
                              color: widget.orderlist.status == "Delivered"
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              height: 8,
                            )),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.orderlist.status == "Delivered"
                                      ? primaryColor
                                      : Colors.grey.shade400),
                              padding: const EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(0.0)
                            .copyWith(left: 20, right: 20),
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: primaryColor),
                              padding: const EdgeInsets.all(10),
                            ),
                            Expanded(
                                child: Container(
                              color: widget.orderlist.status != "Order Placed"
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              height: 8,
                            )),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.orderlist.status != "Order Placed"
                                      ? primaryColor
                                      : Colors.grey.shade400),
                              padding: const EdgeInsets.all(10),
                            ),

                            Expanded(
                                child: Container(
                              color: 
                                      widget.orderlist.status == "Order Picked"
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              height: 8,
                            )),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                              color: widget.orderlist.status == "Order Picked"
                                          ? primaryColor
                                          : Colors.grey.shade400),
                              padding: const EdgeInsets.all(10),
                            ),
                            
                          ],
                        ),
                      ),
                      
                    
                    if (widget.orderlist.driver != 'N/A' &&
                        widget.orderlist.status != "Delivered" &&
                        widget.orderlist.status != "Order Confirmed")
                      const SizedBox(
                        height: 20,
                      ),
                    if (widget.orderlist.driver != 'N/A' &&
                        widget.orderlist.status != "Delivered" &&
                        widget.orderlist.status != "Order Confirmed")
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(imageUrl +
                                                widget
                                                    .orderlist.driver_photo))),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.orderlist.driver,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            widget.orderlist.numberPlate,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        widget.orderlist.driver_phone,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: () => _launchWhatsapp(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0)
                                              .copyWith(left: 8, right: 8),
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Icon(Icons.call),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Call",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Navigation(
                                                  orderList: widget.orderlist),
                                            )),
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                  Icons.navigation_outlined),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Navigate",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
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
                    const SizedBox(
                      height: 20,
                    ),
                    ClipPath(
                      clipper: MovieTicketBothSidesClipper(),
                      child: Container(
                        color: Colors.grey.shade200,
                        width: getWidth(context),
                        height: widget.orderlist.notes != "N/A" && widget.orderlist.pickup_time != "none" ? 620 :  widget.orderlist.notes != "N/A" ? 570 : widget.orderlist.pickup_time != "none" ? 590 : 470,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const SizedBox(
                              //   height: 30,
                              // ),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "#${widget.orderlist.orderNumber}",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          widget.orderlist.customer_code,
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
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Order Date",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "Payment method",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      getdatedate(widget.orderlist.createdAt),
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    widget.orderlist.paymentMethod,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Payment Status",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "Delivery Status",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.orderlist.isPaid == 1
                                        ? "Paid"
                                        : "Pending",
                                    style: GoogleFonts.montserrat(fontSize: 14),
                                  ),
                                  if (widget.orderlist.isPaid == 1)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  else
                                    const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  const Spacer(),
                                  Text(
                                    widget.orderlist.status,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Shipping Address",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Text(
                                  //   "Order Total",
                                  //   style: GoogleFonts.montserrat(
                                  //       fontSize: 16,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: widget.orderlist.isPickup == 0 ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          phone,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          widget.orderlist.deliveryLocation,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          widget.orderlist.landmark,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ) : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pickup at",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          widget.orderlist.seller,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          widget.orderlist.deliveryLocation,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          widget.orderlist.landmark,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Text(
                                  //   "Ksh ${widget.orderlist.total}",
                                  //   style: GoogleFonts.montserrat(
                                  //       fontSize: 20,
                                  //       color: primaryColor,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                ],
                              ),
                              if(widget.orderlist.pickup_time != "none")
                                const SizedBox(height: 10,),
                                if(widget.orderlist.pickup_time != "none")
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      "Pickup time",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                              if(widget.orderlist.pickup_time != "none")
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Card(
                                      color:  Colors.grey.shade200,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: InkWell(
                                        
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0)
                                              .copyWith(left: 8, right: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.access_time),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                widget.orderlist.pickup_time,
                                                style: GoogleFonts
                                                    .montserrat(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                              if (widget.orderlist.notes != "N/A")
                                const SizedBox(
                                  height: 10,
                                ),
                              if (widget.orderlist.notes != "N/A")
                                Text(
                                  "Order Notes:",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              if (widget.orderlist.notes != "N/A")
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(top: 0, left: 0),
                                  child: Container(
                                    width: getWidth(context),
                                    decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.orderlist.notes,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Sub Total",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Ksh ${widget.orderlist.total}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.all(8.0).copyWith(top: 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Delivery Fee",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ),
                                    Text(
                                      "Ksh ${widget.orderlist.deliveryFee}",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.all(8.0).copyWith(top: 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Ksh ${widget.orderlist.order_amount}",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if(widget.orderlist.friendName != 'none')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Order type: ",
                              style: GoogleFonts.montserrat(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Order for friend",
                              style: GoogleFonts.montserrat(
                                  fontSize: 20, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    if(widget.orderlist.friendName != 'none')
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                        child: Row(
                          children: [
                            Text(
                              "Friend Name: ",
                              style: GoogleFonts.montserrat(
                                   fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              widget.orderlist.friendName,
                              style: GoogleFonts.montserrat(
                                   color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    if(widget.orderlist.friendPhone != 'none')
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                        child: Row(
                          children: [
                            Text(
                              "Friend Phone: ",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              widget.orderlist.friendPhone,
                              style: GoogleFonts.montserrat(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    if(widget.orderlist.friendPhone != 'none')
                      const Divider(),
                    
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Order Items",
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.orderlist.orderItems.length,
                      itemBuilder: (context, index) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              height: 90,
                              width: 90,
                              imageUrl: imageUrl +
                                  widget.orderlist.orderItems[index].product
                                      .photo,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: primaryColor,
                                          value: downloadProgress.progress)),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
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
                                          widget.orderlist.orderItems[index]
                                              .item,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
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
                                        widget.orderlist.orderItems[index].category,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        double.parse(widget.orderlist.orderItems[index].weight) != 1 ?
                                        "${(double.parse(widget.orderlist.orderItems[index].weight) * double.parse(widget.orderlist.orderItems[index].quantity)).toStringAsFixed(2)} ${widget.orderlist.orderItems[index].product.unitShort} @ ${widget.orderlist.orderItems[index].sellPrice}" : 
                                        "${(double.parse(widget.orderlist.orderItems[index].weight) * double.parse(widget.orderlist.orderItems[index].quantity)).toStringAsFixed(2)} ${widget.orderlist.orderItems[index].product.unitShort} * ${widget.orderlist.orderItems[index].sellPrice}",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Spacer(),
                                      Text(
                                        () {
                                          return "Ksh ${double.parse(widget.orderlist.orderItems[index].quantity) * double.parse(widget.orderlist.orderItems[index].sellPrice)}";
                                        }(),
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.orderlist.isPaid == 0)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                          child: SizedBox(
                            width: getWidth(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your order has not been paid. Please make payment before you receive it",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Alert(
                                          context: context,
                                          title: "Mpesa Confirmation",
                                          content: Column(
                                            children: [
                                              Text(
                                                "Please confirm the number to send mpesa stk push notification",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                controller: _phoneController,
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.black),
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Phone',
                                                ),
                                              ),
                                            ],
                                          ),
                                          buttons: [
                                            DialogButton(
                                              color: primaryColor,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                initiateMpesa();
                                              },
                                              child: Text(
                                                "SUBMIT",
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            )
                                          ]).show();
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: primaryColor,
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Initiate Mpesa",
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(0.0)
                                        .copyWith(left: 8, right: 8, top: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Container(
                                          height: 1,
                                          color: Colors.black,
                                        )),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text("Or",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                color: Colors.black)),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                            child: Container(
                                          height: 1,
                                          color: Colors.black,
                                        )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Mpesa Classic Procedure",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Go to Mpesa",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Lipa na Mpesa",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Paybill",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Enter paybill",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15)),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(paybill,
                                              style: GoogleFonts.montserrat(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Enter account number as",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15)),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(widget.orderlist.orderNumber,
                                              style: GoogleFonts.montserrat(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Enter amount",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                          ),
                                          Text("Submit",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15))
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 50,
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
