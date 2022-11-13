import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:campdavid/src/ordersuccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cartmodel.dart';
import 'package:http/http.dart' as http;

import '../helpers/databaseHelper.dart';

class CheckOutPage extends StatefulWidget {
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  int selected = 0;
  List<OrderItemsModel> ordersList = [];
  final DBHelper _db = DBHelper();
  late FToast fToast;
  late ArsProgressDialog progressDialog;
  double total = 0;
  String location = "";
  double latitude = 0;
  double longitude = 0;
  String landmark = '';
  String paymentmethod = "mpesa";
  final _descEditingController = TextEditingController();
  String token = "";

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
        });
      }
    });

    _determinePosition().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
      getaddress();
    });

    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
        getTotal();
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showToast("Location permissions are denied. Turn on your location",
            Icons.check, Colors.red);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      _showToast("Location permissions are denied. Turn on your location",
          Icons.check, Colors.red);
    }
    return await Geolocator.getCurrentPosition();
  }

  void getaddress() async {
    if (longitude != 0.0) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      var place = placemarks.first;

      if (place.administrativeArea != null) {
        setState(() {
          location = place.name!;
          landmark = place.street! + " - " + place.administrativeArea!;
        });
      } else {
        setState(() {
          location = place.name!;
          landmark = place.street!;
        });
      }
    } else {
      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });
        getaddress();
      });
    }
  }

  void validateSubmit() async {
      progressDialog.show();
    if (longitude == 0.0) {
      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });
        getaddress();
      });
    }
    if (landmark != '') {

      var items = "";
      if (selected == 0) {
        setState(() {
          paymentmethod = 'mpesa';
        });
      }
      if (selected == 2) {
        setState(() {
          paymentmethod = 'cash';
        });
      }

      for (var element in ordersList) {
        if (items == "") {
          if (element.tag_name != "none") {
            setState(() {
              items =
                  "${element.productId}/${element.quantity}/${element.tag_price}/yes";
            });
          } else {
            setState(() {
              items =
                  "${element.productId}/${element.quantity}/${element.amount}/no";
            });
          }
        } else {
          if (element.tag_name != "none") {
            setState(() {
              items =
                  "$items,${element.productId}/${element.quantity}/${element.tag_price}/yes";
            });
          } else {
            setState(() {
              items =
                  "$items,${element.productId}/${element.quantity}/${element.amount}/no";
            });
          }
        }
      }

      Map data = {
        'landmark': landmark,
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'payment_method': paymentmethod,
        'total_amount': total.toString(),
        'delivery_location': location,
        'total': total.toString(),
        'desc': _descEditingController.text.isEmpty
            ? "N/A"
            : _descEditingController.text,
        'items': items
      };
      var body = json.encode(data);
      var response = await http.post(Uri.parse('${mainUrl}create-order'),
          headers: {
            "Content-Type": "application/json",
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body);

      print(response.body);
      Map<String, dynamic> json1 = json.decode(response.body);
      if (response.statusCode == 200) {
        progressDialog.dismiss();
        if (json1['success'] == "1") {
          _db.deleteAll().then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderSuccess(order_number: json1['order_number']),
                ));
          });
          _showToast(json1['message'], Icons.check, Colors.green);
        } else {
          _showToast(json1['message'], Icons.cancel, Colors.red);
        }
      } else {
        progressDialog.dismiss();
        _showToast(json1['message'], Icons.cancel, Colors.red);
      }
    } else {
      validateSubmit();
    }
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
  }

  Future<LocationResult> showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              kGoogleApiKey,
            )));
    setState(() {
      location = result.name! + " " + result.locality!;
      latitude = result.latLng!.latitude;
      longitude = result.latLng!.longitude;
    });
    getaddress();
    return result;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: const Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Checkout",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 10),
                    child: Text(
                      "Here is Your Order",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    itemCount: ordersList.length,
                    shrinkWrap: true,
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
                                      if (int.parse(
                                              ordersList[index].quantity) >
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
                                            _showToast("Cart Updated",
                                                Icons.check, Colors.green);
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
                                          _showToast("Item Removed from Cart",
                                              Icons.check, Colors.green);
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
                                          OrderItemsModel mitem =
                                              OrderItemsModel(
                                            id: item['id'],
                                            amount: item['amount'],
                                            category: item['category'],
                                            image: item['image'],
                                            tag_id: item['tag_id'],
                                            tag_name: item['tag_name'],
                                            tag_price: item['tag_price'],
                                            productId: item['productId'],
                                            productname: item['productname'],
                                            quantity:
                                                (int.parse(item['quantity']) +
                                                        1)
                                                    .toString(),
                                          );
                                          _db.updateCart(mitem);
                                          _showToast("Cart Updated",
                                              Icons.check, Colors.green);
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
                                      child:
                                          Icon(Icons.add_circle_outline_sharp),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                    child: Text(
                      "Order Notes",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8).copyWith(top: 0),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      onChanged: (value) {},
                      maxLines: 3,
                      controller: _descEditingController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        hintText: "Notes",
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                    child: Text(
                      "Delivery Address",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                    child: InkWell(
                      onTap: () => showPlacePicker(),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined),
                              Text(
                                location != ""
                                    ? "$location - $landmark"
                                    : "Current Location (Tap to change)",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                    child: Text(
                      "Payment Method",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                    child: Row(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selected == 0
                              ? Colors.grey.shade400
                              : Colors.white,
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = 0;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/mpesa.png"))),
                                  ),
                                  Text(
                                    "Mpesa",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (selected == 0) Icon(Icons.check_circle)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: selected == 1
                              ? Colors.grey.shade400
                              : Colors.white,
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selected = 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/cashdelivery.png"))),
                                  ),
                                  Text(
                                    "Cash",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (selected == 1) Icon(Icons.check_circle)
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipPath(
                    clipper: MovieTicketBothSidesClipper(),
                    child: Container(
                      height: 260,
                      color: Colors.grey.shade300,
                      width: getWidth(context),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Order Summary",
                            style: GoogleFonts.montserrat(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Sub Total",
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                ),
                                Text(
                                  "Ksh $total",
                                  style: GoogleFonts.montserrat(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Delivery",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Ksh 0",
                                  style: GoogleFonts.montserrat(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "TOTAL",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "Ksh $total",
                                style: GoogleFonts.montserrat(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              validateSubmit();
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Confirm Order",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                      ),
                                    ),
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
                  ),
                ],
              ),
            ))
          ],
        )),
      ),
    );
  }
}
