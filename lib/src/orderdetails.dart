import 'dart:async';
import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/orderlist.dart';
import 'package:campdavid/src/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String token = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        token = value.getString('token')!;
        name = value.getString('name')!;
        phone = value.getString('phone')!;
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
                    ),
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
                                      Text(
                                        widget.orderlist.driver,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                        ),
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
                        height: 455,
                        color: Colors.grey.shade200,
                        width: getWidth(context),
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
                                          "Order Code",
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
                                    child: Column(
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
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(imageUrl +
                                          widget.orderlist.orderItems[index]
                                              .product.photo))),
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
                                              .product.name,
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
                                        "Beef",
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
                                        "${widget.orderlist.orderItems[index].quantity} * ${widget.orderlist.orderItems[index].sellPrice}",
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
