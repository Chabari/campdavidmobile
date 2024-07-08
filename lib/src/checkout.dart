import 'dart:async';
import 'dart:convert';

// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:awesome_place_search/awesome_place_search.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/userlist.dart';
import 'package:campdavid/src/locationpicker.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:campdavid/src/newlocation.dart';
import 'package:campdavid/src/ordersuccess.dart';
import 'package:campdavid/src/outlets.dart';
import 'package:campdavid/src/resetpasword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
// import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
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
  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignin = GlobalKey<FormState>();
  static final kInitialPosition = const LatLng(-1.03326, 37.06933);

  late ProgressDialog progressDialog;
  List<RidersList> riderslists = [];
  double total = 0;
  bool isObscure = true;
  double subtotal = 0;
  String location = "";
  double latitude = 0;
  double longitude = 0;
  String deviceToken = "";
  bool isShow = true;
  String message = "";
  bool orderforFriend = false;
  bool isLoggedIn = false;
  bool hasAccount = false;
  int selectedItem = 1;
  String landmark = '';
  String paymentmethod = "mpesa";
  final _descEditingController = TextEditingController();
  final _nameController = TextEditingController();
  final _nameFriendController = TextEditingController();
  final _phoneFriendEditingController = TextEditingController();
  TextEditingController timeinput = TextEditingController();
  final _phoneloginCOntroller = TextEditingController();
  final _password_loginCOntroller = TextEditingController();

  final _fnameCOntroller = TextEditingController();
  final _lnameCOntroller = TextEditingController();
  final _phonesigninCOntroller = TextEditingController();
  final _password_signinCOntroller = TextEditingController();
  bool obscure = true;
  // bool obscure = true;

  final _phoneEditingController = TextEditingController();
  String? token;
  // PickResult? selectedPlace;
  bool selectLocation = false;
  bool selectPhone = false;
  bool selectPhoneFriend = false;
  bool selectNameFriend = false;
  bool selectName = false;
  RidersList? selectedRider;
  int selectedDeliveryOption = 0;
  String deliveryfee = "0";
  var items = [
    '0 - 30 Min',
    '30 Min - 1 Hr',
    '1 Hr - 1 Hr 30 Min',
    '1 Hr 30 Min - 2 Hrs',
    '2 Hr - 2 Hrs 30 Min',
    'Select Custom Time'
  ];

  String pickuptime = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);
    // Future.delayed(const Duration(milliseconds: 300)).then((value) {
    //   progressDialog.show();
    // });

    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        if (mounted) {
          setState(() {
            deviceToken = value.getString('device_token')!;
            token = value.getString('token')!;
            isLoggedIn = true;
            _nameController.text = value.getString('name')!;
            _phoneEditingController.text = value.getString('phone')!;
          });
        }
      } else {
        setState(() {
          deviceToken = value.getString('device_token')!;
        });
      }
    });

    requestPermissions();

    // Timer.periodic(const Duration(seconds: 10), (Timer timer) {
    //   if (mounted) {
    //     _determinePosition().then((value) {
    //       if (mounted) {
    //         setState(() {
    //           latitude = value.latitude;
    //           longitude = value.longitude;
    //         });
    //         // checklocation();
    //       }
    //       //getaddress();
    //     });
    //   }
    // });

    _db.getAllCarts().then((scans) {
      if (mounted) {
        setState(() {
          ordersList.addAll(scans);
          getTotal();
        });
      }
    });
  }

  // PickedData? prediction;
  void searchPlaces() async {}

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.location].request();
    if (statuses[Permission.location] == PermissionStatus.granted) {
      _determinePosition().then((value) {
        if (mounted) {
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
          });
          checklocation();
          getaddress();
        }
      });
    } else if (await Permission.location.request().isPermanentlyDenied) {
      await Geolocator.openLocationSettings();
    } else if (await Permission.location.request().isDenied) {
      await Permission.location.request();
      await Geolocator.openLocationSettings();
    }
  }

  _onAlertButtonsPressed(message) async {
    await progressDialog.hide();
    // ignore: use_build_context_synchronously
    Alert(
      context: context,
      type: AlertType.warning,
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: GoogleFonts.montserrat(
            color: primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
        descStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 18),
      ),
      title: "Location Request!",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          color: Colors.black,
          child: Text(
            "CANCEL",
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
          child: Text(
            "OPEN",
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _onAlertButtonsPressed(
          'Location services are disabled. Open settings to enable');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _onAlertButtonsPressed(
            'Location permissions are denied. Turn on your location');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _onAlertButtonsPressed(
          'Location permissions are denied. Turn on your location');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getaddress() async {
    if (longitude != 0.0) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      var place = placemarks.first;

      if (place.administrativeArea != null) {
        setState(() {
          location = place.name!;
          landmark = "${place.street!} - ${place.administrativeArea!}";
        });
      } else {
        setState(() {
          location = place.name!;
          landmark = place.street!;
        });
      }
    } else {
      _determinePosition().then((value) {
        if (mounted) {
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
          });
          checklocation();
          getaddress();
        }
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void checklocation() async {
    await progressDialog.show();
    Map data = {
      'longitude': longitude.toString(),
      'latitude': latitude.toString()
    };
    var body = json.encode(data);
    var response = await http.post(Uri.parse('${mainUrl}getRadius'),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: body);

    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      await progressDialog.hide();

      if (json1['success'] == "true") {
        setState(() {
          isShow = true;
          deliveryfee = json1['delivery_fee'].toStringAsFixed(0);
          getTotal();
        });
      } else {
        setState(() {
          // isShow = false;
          message = json1['message'];
        });

        // ignore: use_build_context_synchronously
        Alert(
          context: context,
          type: AlertType.warning,
          style: AlertStyle(
            backgroundColor: Colors.white,
            titleStyle: GoogleFonts.montserrat(
                color: primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
            descStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 18),
          ),
          title: "Location Check!",
          desc: message,
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectLocation = true;
                  location = "";
                  landmark = "";
                  latitude = 0;
                  longitude = 0;
                });
              },
              color: Colors.black,
              child: Text(
                "CANCEL",
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
              ),
            ),
            DialogButton(
              color: primaryColor,
              child: Text(
                "EXPLORE",
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
              ),
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  selectLocation = true;
                  location = "";
                  landmark = "";
                  latitude = 0;
                  longitude = 0;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Outlets(),
                    ));
              },
            )
          ],
        ).show();
      }
    } else {
      await progressDialog.hide();
      showToast(json1['message'], Colors.red);
    }
  }

  void validateSubmit() async {
    if (ordersList.isEmpty) {
      showToast("Select Items to order", Colors.red);
      return;
    }
    if (orderforFriend) {
      if (_nameFriendController.text.isEmpty) {
        showToast("Please enter your friend's name", Colors.red);
        setState(() {
          selectNameFriend = true;
        });
        return;
      }
      if (_phoneFriendEditingController.text.isEmpty) {
        showToast("Please enter your friend's phone number", Colors.red);
        setState(() {
          selectPhoneFriend = true;
        });
        return;
      }
    }
    if (location != "" &&
        _phoneEditingController.text.isNotEmpty &&
        _nameController.text.isNotEmpty) {
      await progressDialog.show();

      if (location != '') {
        var items = [];
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
          var itm = {
            'product_id': element.productId,
            'quantity': element.quantity,
            'weight': element.weight,
            'amount': element.amount,
            'packageId': element.packageId,
            'tagId': element.tagId,
            'tagname': element.tagName,
          };
          items.add(itm);
        }

        Map data = {
          'landmark': landmark,
          'deviceToken': deviceToken,
          'friend_name': _nameFriendController.text.isNotEmpty
              ? _nameFriendController.text
              : "none",
          'friend_phone': _phoneFriendEditingController.text.isNotEmpty
              ? _phoneFriendEditingController.text
              : "none",
          'longitude': longitude.toString(),
          'selectedDeliveryOption': selectedDeliveryOption.toString(),
          'delivery_fee': deliveryfee,
          'pickup':
              selectedRider != null ? selectedRider!.id.toString() : "N/A",
          'latitude': latitude.toString(),
          'payment_method': paymentmethod,
          'name': _nameController.text,
          'phone': _phoneEditingController.text,
          'pickup_time': pickuptime,
          'total_amount': subtotal.toString(),
          'delivery_location': location,
          'total': subtotal.toString(),
          'desc': _descEditingController.text.isEmpty
              ? "N/A"
              : _descEditingController.text,
          'items': items
        };
        var body = json.encode(data);
        if (token != null) {
          var response =
              await http.post(Uri.parse('${mainUrl}create-new-order'),
                  headers: {
                    "Content-Type": "application/json",
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: body);

          Map<String, dynamic> json1 = json.decode(response.body);
          if (response.statusCode == 200) {
            await progressDialog.hide();
            if (json1['success'] == "1") {
              _db.deleteAll().then((value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderSuccess(order_number: json1['order_number']),
                    ));
              });
              showToast(json1['message'], Colors.green);
            } else {
              showToast(json1['message'], Colors.red);
            }
          } else {
            await progressDialog.hide();
            showToast(json1['message'], Colors.red);
          }
        } else {
          var response = await http.post(Uri.parse('${mainUrl}create_order'),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);

          Map<String, dynamic> json1 = json.decode(response.body);
          if (response.statusCode == 200) {
            await progressDialog.hide();
            if (json1['success'] == "1") {
              _db.deleteAll().then((value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderSuccess(order_number: json1['order_number']),
                    ));
              });
              showToast(json1['message'], Colors.green);
            } else {
              showToast(json1['message'], Colors.red);
            }
          } else {
            await progressDialog.hide();
            showToast(json1['message'], Colors.red);
          }
        }
      } else {
        validateSubmit();
      }
    } else {
      if (location == "") {
        setState(() {
          selectLocation = true;
        });
      }
      if (_phoneEditingController.text.isEmpty) {
        setState(() {
          selectPhone = true;
        });
      }
      if (_nameController.text.isEmpty) {
        setState(() {
          selectName = true;
        });
      }

      showToast("Please enter required details", Colors.red);
    }
  }

  void showToast(message, color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void getTotal() {
    total = double.parse(deliveryfee);
    ordersList.forEach((element) {
      setState(() {
        total +=
            (double.parse(element.amount) * double.parse(element.quantity));
      });
    });
    setState(() {
      subtotal = total - double.parse(deliveryfee);
    });
  }

  void _openDialog(cntx) async {
    await Navigator.of(cntx).push(MaterialPageRoute<String>(
        builder: (BuildContext cntx) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Select Outlet",
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
                backgroundColor: primaryColor,
                actions: const [],
              ),
              body: StatefulBuilder(builder: (context, setmState) {
                return Container(
                  width: MediaQuery.of(cntx).size.width,
                  height: MediaQuery.of(cntx).size.height,
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ListView.builder(
                      itemCount: riderslists.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(top: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            setmState(() {
                              selectedRider = riderslists[index];
                              selectedDeliveryOption = 1;
                              deliveryfee = "0";
                            });
                            setState(() {
                              selectedRider = riderslists[index];
                              selectedDeliveryOption = 1;
                              selectLocation = false;
                              location = riderslists[index].location;
                              landmark = riderslists[index].landmark;
                              deliveryfee = "0";
                              latitude =
                                  double.parse(riderslists[index].latitude);
                              longitude =
                                  double.parse(riderslists[index].longitude);
                            });
                          },
                          child: Column(
                            children: [
                              Card(
                                color: Colors.grey.shade100,
                                margin:
                                    const EdgeInsets.only(left: 0, right: 0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            riderslists[index].name,
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          const Spacer(),
                                          if (selectedRider != null &&
                                              selectedRider!.id ==
                                                  riderslists[index].id)
                                            const Icon(
                                              Icons.radio_button_checked,
                                              size: 30,
                                            )
                                          else
                                            const Icon(
                                              Icons.radio_button_off,
                                              size: 30,
                                            )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Location:",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            riderslists[index].location,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Landmark:",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            riderslists[index].landmark,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Contacts:",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            riderslists[index].phone,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (selectedRider != null &&
                                  selectedRider!.id == riderslists[index].id)
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    "Pickup time",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              if (selectedRider != null &&
                                  selectedRider!.id == riderslists[index].id)
                                SizedBox(
                                  width: getWidth(context),
                                  height: 50,
                                  child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: ListView.builder(
                                        itemCount: items.length,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) => Card(
                                          color: pickuptime == items[index]
                                              ? Colors.grey.shade200
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: InkWell(
                                            onTap: () async {
                                              if (items[index] ==
                                                  "Select Custom Time") {
                                                TimeOfDay? pickedTime =
                                                    await showTimePicker(
                                                  initialTime: TimeOfDay.now(),
                                                  context: context,
                                                );

                                                if (pickedTime != null) {
                                                  // print(pickedTime.format(
                                                  //     context)); //output 10:51 PM
                                                  // DateTime parsedTime =
                                                  //     DateFormat.jm().parse(
                                                  //         pickedTime
                                                  //             .format(context)
                                                  //             .toString());
                                                  // String formattedTime =
                                                  //     DateFormat('HH:mm')
                                                  //         .format(parsedTime);
                                                  // print(
                                                  //     formattedTime); //output 14:59:00

                                                  setState(() {
                                                    timeinput.text = pickedTime
                                                        .format(context);
                                                    pickuptime = pickedTime
                                                        .format(context);
                                                  });

                                                  setmState(() {
                                                    timeinput.text = pickedTime
                                                        .format(context);
                                                    pickuptime = pickedTime
                                                        .format(context);
                                                  });
                                                } else {}
                                              } else {
                                                setState(() {
                                                  timeinput.text = items[index];
                                                  pickuptime = items[index];
                                                });

                                                setmState(() {
                                                  timeinput.text = items[index];
                                                  pickuptime = items[index];
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0)
                                                  .copyWith(left: 8, right: 8),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.access_time),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    items[index],
                                                    style: GoogleFonts
                                                        .montserrat(),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                ),
                              if (selectedRider != null &&
                                  selectedRider!.id == riderslists[index].id)
                                const SizedBox(
                                  height: 10,
                                ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 4),
                                        color: Colors.grey.shade400,
                                        blurRadius: 4,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  onTap: () {
                                    setmState(() {
                                      selectedRider = riderslists[index];
                                      selectedDeliveryOption = 1;
                                      selectLocation = false;
                                      location = riderslists[index].location;
                                      landmark = riderslists[index].landmark;
                                      latitude = double.parse(
                                          riderslists[index].latitude);
                                      longitude = double.parse(
                                          riderslists[index].longitude);
                                    });
                                    // if (riderslists[index].approximatecost !=
                                    //     0) {
                                    //   setState(() {
                                    //     deliveryfee = riderslists[index]
                                    //         .approximatecost
                                    //         .toString();
                                    //   });
                                    //   setmState(() {
                                    //     deliveryfee = riderslists[index]
                                    //         .approximatecost
                                    //         .toString();
                                    //   });
                                    // }
                                    setState(() {
                                      selectedRider = riderslists[index];

                                      selectedDeliveryOption = 1;
                                      selectLocation = false;
                                      location = riderslists[index].location;
                                      landmark = riderslists[index].landmark;
                                      latitude = double.parse(
                                          riderslists[index].latitude);
                                      longitude = double.parse(
                                          riderslists[index].longitude);
                                    });

                                    Future.delayed(
                                            const Duration(milliseconds: 500))
                                        .then((value) async {
                                      progressDialog.show();
                                      Future.delayed(const Duration(seconds: 2))
                                          .then((value) async {
                                        await progressDialog.hide();
                                        Navigator.pop(context);
                                        getTotal();
                                      });
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Pick Here",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }));
        },
        fullscreenDialog: true));
  }

  Future<List<RidersList>> fetchoutlets() async {
    final uri = Uri.parse("${mainUrl}outlets");
    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Accept': 'application/json'
    });
    return ridersListFromJson(res.body);
  }

  void _viewmoreModalBottomSheet(context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(8).copyWith(top: 15),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.4,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Select Option",
                      style: GoogleFonts.montserrat(fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    await progressDialog.show();
                    riderslists.clear();
                    fetchoutlets().then((value) async {
                      await progressDialog.hide();

                      setState(() {
                        riderslists.addAll(value);
                        deliveryfee = "0";
                        getTotal();
                      });
                      Navigator.pop(context);
                      _openDialog(context);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20)),
                    height: height * 0.065,
                    child: Center(
                      child: Text(
                        "Pickup",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final results = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => NewLocationPicker()),
                    );

                    if (results != null) {
                      LatLng pickedLocation = results['current_location'];
                      var place = results['place'];

                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              pickedLocation.latitude,
                              pickedLocation.longitude);
                      if (placemarks.isNotEmpty) {
                        Placemark place = placemarks.first;
                        setState(() {
                          landmark =
                              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
                        });
                      }

                      setState(() {
                        latitude = pickedLocation.latitude;
                        longitude = pickedLocation.longitude;
                        location = place;
                        checklocation();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20)),
                    height: height * 0.065,
                    child: Center(
                      child: Text(
                        "Pick Location",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }

  void openDialogSignin(cntx) async {
    await Navigator.of(cntx).push(MaterialPageRoute<String>(
        builder: (BuildContext cntx) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Login/Create Account",
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
                backgroundColor: primaryColor,
                actions: const [],
              ),
              body: StatefulBuilder(builder: (context, setmState) {
                return Container(
                  width: MediaQuery.of(cntx).size.width,
                  height: MediaQuery.of(cntx).size.height,
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: InkWell(
                                onTap: () {
                                  setmState(() {
                                    selectedItem = 0;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: selectedItem == 0
                                          ? Colors.grey.shade300
                                          : Colors.white,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              Expanded(
                                  child: InkWell(
                                onTap: () {
                                  setmState(() {
                                    selectedItem = 1;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: selectedItem == 1
                                          ? Colors.grey.shade300
                                          : Colors.white,
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text(
                                        "Signin",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (selectedItem == 0)
                            Form(
                              key: _formKeyLogin,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  if (hasAccount)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        "Please login to proceed",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "Phone Number",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      maxLength: 13,
                                      onChanged: (value) {},
                                      controller: _phoneloginCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Colors.black87,
                                        ),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        hintText: " 0*********",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "Password",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: isObscure,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      onChanged: (value) {},
                                      controller: _password_loginCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        prefixIcon: InkWell(
                                            onTap: () {
                                              setmState(() {
                                                isObscure = !isObscure;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.password,
                                              color: Colors.black87,
                                            )),
                                        hintText: "Password",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(15),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 4),
                                            color: Colors.grey.shade400,
                                            blurRadius: 4,
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: InkWell(
                                      onTap: () {
                                        validateSubmitLogin();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "LOGIN",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setmState(() {
                                        selectedItem = 1;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.center,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            "SIgnup",
                                            style: GoogleFonts.montserrat(
                                                color: primaryColor,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            )
                          else
                            Form(
                              key: _formKeySignin,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "First Name",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType: TextInputType.text,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      onChanged: (value) {},
                                      validator: (input) => input!.isEmpty
                                          ? "Firstname should be valid"
                                          : null,
                                      controller: _fnameCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Colors.black87,
                                        ),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        hintText: "First Name",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "Last Name",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType: TextInputType.text,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      onChanged: (value) {},
                                      validator: (input) => input!.isEmpty
                                          ? "Last name should be valid"
                                          : null,
                                      controller: _lnameCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Colors.black87,
                                        ),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        hintText: "Last Name",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "Phone Number",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      maxLength: 10,
                                      onChanged: (value) {},
                                      validator: (input) => input!.isEmpty
                                          ? "Phone should be valid"
                                          : null,
                                      controller: _phonesigninCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Colors.black87,
                                        ),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        hintText: " 0*********",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      "Password",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.all(10)
                                        .copyWith(top: 5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: TextFormField(
                                      cursorColor: primaryColor,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: obscure,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      ),
                                      onChanged: (value) {},
                                      validator: (input) => input!.isEmpty
                                          ? "Password should not be empty"
                                          : null,
                                      controller: _password_signinCOntroller,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 0.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32))),
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        counterText: "",
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        prefixIcon: InkWell(
                                            onTap: () {
                                              setmState(() {
                                                obscure = !obscure;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.password,
                                              color: Colors.black87,
                                            )),
                                        hintText: "Password",
                                        hintStyle: GoogleFonts.montserrat(
                                            color: Colors.black87,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(15),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 4),
                                            color: Colors.grey.shade400,
                                            blurRadius: 4,
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    child: InkWell(
                                      onTap: () {
                                        validateSubmitsignin();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "SIGNUP",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setmState(() {
                                        selectedItem = 0;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.center,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Already have an account? ",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            "Login",
                                            style: GoogleFonts.montserrat(
                                                color: primaryColor,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResetPassword(
                                        phone: _phoneloginCOntroller
                                                .text.isNotEmpty
                                            ? _phoneloginCOntroller.text
                                            : _phoneEditingController
                                                    .text.isNotEmpty
                                                ? _phoneEditingController.text
                                                : _phonesigninCOntroller
                                                        .text.isNotEmpty
                                                    ? _phonesigninCOntroller
                                                        .text
                                                    : ""),
                                  )),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: Text(
                                  "Forgot Password? ",
                                  style: GoogleFonts.montserrat(
                                      color: secondaryColor, fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                );
              }));
        },
        fullscreenDialog: true));
  }

  void validateSubmitLogin() async {
    var formstate = _formKeyLogin.currentState;
    if (formstate!.validate()) {
      await progressDialog.show();
      var data = {
        'password': _password_loginCOntroller.text,
        'is_checkout': 'yes',
        'phone': _phoneloginCOntroller.text
      };
      var body = json.encode(data);
      var response = await http.post(Uri.parse("${mainUrl}user-signin"),
          headers: {
            "Content-Type": "application/json",
            'Accept': 'application/json',
          },
          body: body);
      final mpref = await SharedPreferences.getInstance();

      Map<String, dynamic> json1 = json.decode(response.body);
      if (response.statusCode == 200) {
        // await progressDialog.hide();
        if (json1['success'] == "1") {
          Navigator.pop(context);
          Map<String, dynamic> user = json1['user'];
          setState(() {
            token = json1['token'];
            isLoggedIn = true;
            _nameController.text = user['first_name'] + " " + user['last_name'];
            _phoneEditingController.text = user['phone'];
            mpref.setString("token", json1['token']);
            mpref.setString(
                "name", user['first_name'] + " " + user['last_name']);
            mpref.setString("user_id", user['id'].toString());
            mpref.setString("phone", user['phone']);
            mpref.setString("call_phone", json1['call_phone']);
            mpref.setString("support_email", json1['support_email']);
            mpref.setString("orders", json1['orders'].toString());
            mpref.setString("paybill", json1['paybill']);
            mpref.setBool('isFirst', false);
          });
          if (mounted) {
            Fluttertoast.showToast(
                msg: json1['message'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          await progressDialog.show();
          Future.delayed(const Duration(seconds: 1)).then((value) async {
            await progressDialog.hide();
            Navigator.pop(context);
          });
        } else if (json1['success'] == "2") {
          await progressDialog.hide();
          Fluttertoast.showToast(
              msg: json1['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          await progressDialog.hide();
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
        await progressDialog.hide();
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
  }

  void validateSubmitsignin() async {
    var formstate = _formKeySignin.currentState;
    if (formstate!.validate()) {
      await progressDialog.show();
      var data = {
        'phone': _phonesigninCOntroller.text,
        'password': _password_signinCOntroller.text,
        'is_checkout': 'yes',
        'first_name': _fnameCOntroller.text,
        'last_name': _lnameCOntroller.text
      };
      var body = json.encode(data);
      var response = await http.post(Uri.parse("${mainUrl}user-signup"),
          headers: {
            "Content-Type": "application/json",
            'Accept': 'application/json',
          },
          body: body);
      final mpref = await SharedPreferences.getInstance();

      Map<String, dynamic> json1 = json.decode(response.body);
      if (response.statusCode == 200) {
        // await progressDialog.hide();
        if (json1['success'] == "1") {
          Map<String, dynamic> user = json1['user'];
          setState(() {
            token = json1['token'];
            isLoggedIn = true;
            _nameController.text = user['first_name'] + " " + user['last_name'];
            _phoneEditingController.text = user['phone'];
            mpref.setString("token", json1['token']);
            mpref.setString(
                "name", user['first_name'] + " " + user['last_name']);
            mpref.setString("user_id", user['id'].toString());
            mpref.setString("phone", user['phone']);
            mpref.setString("call_phone", json1['call_phone']);
            mpref.setString("support_email", json1['support_email']);
            mpref.setString("orders", json1['orders'].toString());
            mpref.setString("paybill", json1['paybill']);
            mpref.setBool('isFirst', false);
          });
          if (mounted) {
            Fluttertoast.showToast(
                msg: json1['message'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          await progressDialog.show();
          Future.delayed(const Duration(seconds: 1)).then((value) async {
            await progressDialog.hide();
            Navigator.pop(context);
          });
        } else if (json1['success'] == "2") {
          await progressDialog.hide();
          Fluttertoast.showToast(
              msg: json1['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          await progressDialog.hide();
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
        await progressDialog.hide();
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
  }

  void showAwesome(message, action) {
    Alert(
      context: context,
      type: AlertType.warning,
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: GoogleFonts.lato(
            color: primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
        descStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 18),
      ),
      title: "Login Check!",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          child: Text(
            "Close",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () {
            Get.back();
            //   btnOkOnPress: () {
            if (action == "Create") {
              var texts = _nameController.text.split(' ');
              var textf = texts[0];
              if (texts.length > 1) {
                var textl = texts[1];
                if (textl.isNotEmpty) {
                  setState(() {
                    _lnameCOntroller.text = textl;
                  });
                }
              }

              setState(() {
                _fnameCOntroller.text = textf;
              });
              openDialogSignin(context);
            } else {
              openDialogSignin(context);
            }
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
          child: Text(
            action,
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }

  void checkphone() async {
    await progressDialog.show();
    var data = {'phone': _phoneEditingController.text};
    var body = json.encode(data);
    var response = await http.post(Uri.parse("${mainUrl}checkUser"),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: body);

    Map<String, dynamic> json1 = json.decode(response.body);
    String name = _nameController.text.split(' ')[0];
    await progressDialog.hide();
    if (response.statusCode == 200) {
      // await progressDialog.hide();
      if (json1['success'] == "1") {
        setState(() {
          selectedItem = 0;
          hasAccount = true;
          _phoneloginCOntroller.text = _phoneEditingController.text;
        });

        showAwesome("Dear $name, ${json1['message']}", "Login");
      } else {
        await progressDialog.hide();

        setState(() {
          selectedItem = 1;
          hasAccount = false;
          _phonesigninCOntroller.text = _phoneEditingController.text;
        });

        showAwesome("Dear $name, ${json1['message']}", "Create");
      }
    } else {
      await progressDialog.hide();
      showToast(json1['message'], Colors.red);
    }
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
                  if (isShow)
                    Padding(
                      padding: const EdgeInsets.all(8.0).copyWith(top: 10),
                      child: Text(
                        "Here is Your Order",
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (isShow)
                    ListView.builder(
                      itemCount: ordersList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.all(6),
                        elevation: 3,
                        child: Row(
                          children: [
                            Container(
                              height: 100,
                              width: 90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          imageUrl + ordersList[index].image),
                                      fit: BoxFit.cover)),
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
                                          ordersList[index].tagName != "none"
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
                                      if (ordersList[index].tagName != "none")
                                        Text(
                                          "${ordersList[index].tagName} @ Ksh ",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12, color: Colors.grey),
                                        )
                                      else
                                        Text(
                                          " Ksh",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      if (ordersList[index].tagName != "none")
                                        Text(
                                          ordersList[index].amount,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      else
                                        Row(
                                          children: [
                                            Text(
                                              ordersList[index].amount,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              " * (${(double.parse(ordersList[index].weight) * double.parse(ordersList[index].quantity)).toStringAsFixed(2)} ${ordersList[index].unitName})",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                if (ordersList[index].package != "none")
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        ordersList[index].package,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (double.parse(
                                                ordersList[index].quantity) >
                                            1) {
                                          _db
                                              .checkexistsItem(
                                                  ordersList[index].productId,
                                                  ordersList[index].tagId)
                                              .then((value) {
                                            if (value.length > 0) {
                                              var item = value.first;
                                              OrderItemsModel mitem =
                                                  OrderItemsModel(
                                                id: item['id'],
                                                amount: item['amount'],
                                                category: item['category'],
                                                package: item['package'],
                                                image: item['image'],
                                                unitName: item['unitName'],
                                                productId: item['productId'],
                                                productname:
                                                    item['productname'],
                                                tagId: item['tagId'],
                                                tagName: item['tagName'],
                                                weight: item['weight'],
                                                packageId: item['packageId'],
                                                quantity: (double.parse(
                                                            item['quantity']) -
                                                        1)
                                                    .toString(),
                                              );
                                              _db.updateCart(mitem);
                                              showToast(
                                                  "Cart Updated", Colors.green);
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
                                                  ordersList[index].productId,
                                                  ordersList[index].tagId)
                                              .then((value) {
                                            showToast("Item Removed from Cart",
                                                Colors.green);
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
                                        color: Colors.white,
                                        child:
                                            Icon(Icons.remove_circle_outline),
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
                                                ordersList[index].productId,
                                                ordersList[index].tagId)
                                            .then((value) {
                                          if (value.length > 0) {
                                            var item = value.first;
                                            OrderItemsModel mitem =
                                                OrderItemsModel(
                                              id: item['id'],
                                              amount: item['amount'],
                                              category: item['category'],
                                              package: item['package'],
                                              image: item['image'],
                                              unitName: item['unitName'],
                                              productId: item['productId'],
                                              productname: item['productname'],
                                              tagId: item['tagId'],
                                              tagName: item['tagName'],
                                              weight: item['weight'],
                                              packageId: item['packageId'],
                                              quantity: (double.parse(
                                                          item['quantity']) +
                                                      1)
                                                  .toString(),
                                            );
                                            _db.updateCart(mitem);
                                            showToast(
                                                "Cart Updated", Colors.green);
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
                                        color: Colors.white,
                                        child: Icon(
                                            Icons.add_circle_outline_sharp),
                                      ),
                                    ),
                                    const Spacer(),
                                    // if (ordersList[index].tagName != "none")
                                    //   Text(
                                    //     "Ksh ${double.parse(ordersList[index].amount) * double.parse(ordersList[index].quantity) * double.parse(ordersList[index].weight)}",
                                    //     style: GoogleFonts.montserrat(
                                    //         fontSize: 18,
                                    //         color: primaryColor,
                                    //         fontWeight: FontWeight.bold),
                                    //   )
                                    // else
                                    Text(
                                      "Ksh ${double.parse(ordersList[index].amount) * double.parse(ordersList[index].quantity)}",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    )
                                  ],
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                  if (isShow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              hintText:
                                  "Notes (eg. How your order should be packaged)",
                              hintStyle: GoogleFonts.montserrat(
                                  color: primaryColor, fontSize: 18),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(8.0).copyWith(top: 20),
                              child: Text(
                                "Customer Details",
                                style: GoogleFonts.montserrat(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Name",
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(10).copyWith(top: 5),
                          elevation: 3,
                          shape: selectName
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: primaryColor))
                              : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            cursorColor: primaryColor,
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                            ),
                            onChanged: (value) {},
                            validator: (input) =>
                                input!.isEmpty ? "name should be valid" : null,
                            controller: _nameController,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32))),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.black87,
                              ),
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              counterText: "",
                              contentPadding: const EdgeInsets.all(12),
                              hintText: "Enter your Name",
                              hintStyle: GoogleFonts.montserrat(
                                  color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Phone Number",
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(10).copyWith(top: 5),
                          elevation: 3,
                          shape: selectPhone
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: primaryColor))
                              : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            cursorColor: primaryColor,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                            ),
                            maxLength: 10,
                            onChanged: (value) {},
                            validator: (input) =>
                                input!.isEmpty ? "Phone should be valid" : null,
                            controller: _phoneEditingController,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32))),
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: Colors.black87,
                              ),
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              counterText: "",
                              contentPadding: const EdgeInsets.all(12),
                              hintText: " 0*********",
                              hintStyle: GoogleFonts.montserrat(
                                  color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(8.0).copyWith(top: 20),
                              child: Text(
                                "More Options",
                                style: GoogleFonts.montserrat(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderforFriend = !orderforFriend;
                            });
                          },
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              orderforFriend
                                  ? const Icon(Icons.check_box)
                                  : const Icon(Icons.check_box_outline_blank),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Order for a Friend",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (orderforFriend)
                          const SizedBox(
                            height: 20,
                          ),
                        if (orderforFriend)
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Friend Name",
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                        if (orderforFriend)
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(10).copyWith(top: 5),
                            elevation: 3,
                            shape: selectNameFriend
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: primaryColor))
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              cursorColor: primaryColor,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                              ),
                              onChanged: (value) {},
                              validator: (input) => input!.isEmpty
                                  ? "name should be valid"
                                  : null,
                              controller: _nameFriendController,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 0.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32))),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.black87,
                                ),
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                counterText: "",
                                contentPadding: const EdgeInsets.all(12),
                                hintText: "Enter your Friend's Name",
                                hintStyle: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                        if (orderforFriend)
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Friend's Phone Number",
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                        if (orderforFriend)
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(10).copyWith(top: 5),
                            elevation: 3,
                            shape: selectPhoneFriend
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: primaryColor))
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              cursorColor: primaryColor,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                              ),
                              maxLength: 10,
                              onChanged: (value) {},
                              validator: (input) => input!.isEmpty
                                  ? "Phone should be valid"
                                  : null,
                              controller: _phoneFriendEditingController,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 0.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32))),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.black87,
                                ),
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                counterText: "",
                                contentPadding: const EdgeInsets.all(12),
                                hintText: " 0*********",
                                hintStyle: GoogleFonts.montserrat(
                                    color: Colors.grey, fontSize: 18),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                          child: Text(
                            orderforFriend
                                ? "Delivery Address (Your Friend's Location)"
                                : "Delivery Address",
                            style: GoogleFonts.montserrat(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (selectedDeliveryOption == 0)
                          Padding(
                            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                            child: InkWell(
                              onTap: () => _viewmoreModalBottomSheet(context),
                              child: Card(
                                color: Colors.white,
                                shape: selectLocation
                                    ? RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: primaryColor))
                                    : RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined),
                                      Expanded(
                                        child: Text(
                                          location != ""
                                              ? " $location"
                                              : "Current Location (Tap to change)",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 3,
                            child: Column(
                              children: [
                                Card(
                                  color: Colors.grey.shade100,
                                  margin:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              selectedRider!.name,
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.radio_button_checked,
                                              size: 30,
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Location:",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              selectedRider!.location,
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Landmark:",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              selectedRider!.landmark,
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Contacts:",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              selectedRider!.phone,
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (pickuptime != "")
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      "Pickup time",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                if (pickuptime != "")
                                  const SizedBox(
                                    height: 4,
                                  ),
                                if (pickuptime != "")
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Card(
                                      color: Colors.grey.shade200,
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
                                                pickuptime,
                                                style: GoogleFonts.montserrat(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (pickuptime != "")
                                  const SizedBox(
                                    height: 10,
                                  ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: InkWell(
                                    onTap: () {
                                      _viewmoreModalBottomSheet(context);
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Change Address",
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
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
                                        if (selected == 0)
                                          const Icon(Icons.check_circle)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ClipPath(
                          clipper: MovieTicketBothSidesClipper(),
                          child: Container(
                            height: 300,
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(top: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Sub Total",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18),
                                        ),
                                      ),
                                      Text(
                                        "Ksh $subtotal",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(top: 0),
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
                                        "Ksh $deliveryfee",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18),
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (token != null) {
                                      if (double.parse(deliveryfee) > 0) {
                                        validateSubmit();
                                      } else {
                                        if (selectedDeliveryOption == 0) {
                                          showToast(
                                              "Pick correct delivery Location",
                                              Colors.red);
                                        } else {
                                          deliveryfee = "0";
                                          validateSubmit();
                                        }
                                      }
                                    } else {
                                      if (_nameController.text.isNotEmpty) {
                                        if (_phoneEditingController
                                            .text.isNotEmpty) {
                                          checkphone();
                                        } else {
                                          showToast("Enter mobile number",
                                              Colors.red);
                                        }
                                      } else {
                                        showToast(
                                            "Enter your name", Colors.red);
                                      }
                                    }
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: primaryColor,
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                    )
                  else
                    Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          height: 120,
                          width: 120,
                          // decoration: const BoxDecoration(
                          //   image: DecorationImage(image: AssetImage("assets/images/locationoff.png"),)
                          // ),
                          child: Image.asset(
                            "assets/images/locationoff.png",
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                message,
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: Colors.grey.shade400,
                                  blurRadius: 4,
                                )
                              ],
                              borderRadius: BorderRadius.circular(32)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Outlets(),
                                  ));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Explore Our Branches",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ))
          ],
        )),
      ),
    );
  }
}
