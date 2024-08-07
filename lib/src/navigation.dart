import 'dart:async';
import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

import '../helpers/orderlist.dart';

class Navigation extends StatefulWidget {
  OrderList orderList;
  Navigation({required this.orderList});

  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  String location = "";
  double latitude = -1.03326;
  double longitude = 37.06933;
  double latitude2 = -1.03326;
  double longitude2 = 37.06933;
  String token = "";
  bool isLoading = true;
  String landmark = '';
  String riderLocation = "";
  final _customerCodeController = TextEditingController();
  late FToast fToast;
  final Completer<GoogleMapController> _controller = Completer();
  static CameraPosition? _kGooglePlex;
  Map<MarkerId, Marker> markers = {};
  late Position _currentPosition;
  String _currentAddress = '';

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  // PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();

    SharedPreferences.getInstance().then((value) {
      setState(() {
        token = value.getString('token')!;
      });
    });
    setState(() {
      latitude2 = double.parse(widget.orderList.driver_latitude);
      longitude2 = double.parse(widget.orderList.driver_longitude);
    });

    fToast.init(context);

    _determinePosition().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
        _kGooglePlex = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 13,
        );

        _addMarker(
          LatLng(latitude, longitude),
          "origin",
          BitmapDescriptor.defaultMarker,
        );
        // Add destination marker
        _addMarker(
          LatLng(latitude2, longitude2),
          "destination",
          BitmapDescriptor.defaultMarkerWithHue(90),
        );

        // _getPolyline();
      });

      getaddress();
    });
    Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (mounted) {
        fetchOrder(widget.orderList.id.toString());
      }
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: 'Really cool place',
        snippet: '5 Star Rating',
      ),
    );
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  // _getPolyline() async {
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     kGoogleApiKey,
  //     PointLatLng(latitude, longitude),
  //     PointLatLng(latitude2, longitude2),
  //     travelMode: TravelMode.driving,
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   _addPolyLine();
  // }

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
      Geolocator.openLocationSettings();

      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
          _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.4746,
          );

          _addMarker(
            LatLng(latitude, longitude),
            "origin",
            BitmapDescriptor.defaultMarker,
          );
          // Add destination marker
          _addMarker(
            LatLng(latitude2, longitude2),
            "destination",
            BitmapDescriptor.defaultMarkerWithHue(90),
          );

          // _getPolyline();
        });

        getaddress();
      });
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getRiderAddress() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    var place = placemarks.first;

    if (place.administrativeArea != null) {
      setState(() {
        riderLocation = "${place.name!} ${place.street!}";
      });
    } else {
      setState(() {
        riderLocation = "${place.name!} ${place.street!}";
      });
    }
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
          _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.4746,
          );

          _addMarker(
            LatLng(latitude, longitude),
            "origin",
            BitmapDescriptor.defaultMarker,
          );
          // Add destination marker
          _addMarker(
            LatLng(latitude2, longitude2),
            "destination",
            BitmapDescriptor.defaultMarkerWithHue(90),
          );

          // _getPolyline();
        });

        getaddress();
      });
    }
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

  _launchWhatsapp(call_phone) async {
    var whatsappAndroid = Uri();

    whatsappAndroid = Uri.parse("tel:$call_phone");

    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    }
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
        widget.orderList = OrderList.fromJson(json1['order']);
        latitude2 = double.parse(widget.orderList.driver_latitude);
        longitude2 = double.parse(widget.orderList.driver_longitude);

        getRiderAddress();
      });
      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
          _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 13,
          );

          _addMarker(
            LatLng(latitude, longitude),
            "origin",
            BitmapDescriptor.defaultMarker,
          );
          // Add destination marker
          _addMarker(
            LatLng(latitude2, longitude2),
            "destination",
            BitmapDescriptor.defaultMarkerWithHue(90),
          );

          // _getPolyline();
        });

        getaddress();
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: Stack(
          children: [
            if (_kGooglePlex != null)
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex!,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                markers: Set<Marker>.of(markers.values),
                circles: Set.from(
                  [
                    Circle(
                      circleId: CircleId('currentCircle'),
                      center: LatLng(latitude, longitude),
                      radius: 2000,
                      fillColor: Colors.blue.shade100.withOpacity(0.5),
                      strokeColor: Colors.blue.shade100.withOpacity(0.1),
                    ),
                    Circle(
                      circleId: CircleId('destCircle'),
                      center: LatLng(latitude2, longitude2),
                      radius: 2000,
                      fillColor: Colors.blue.shade100.withOpacity(0.5),
                      strokeColor: Colors.blue.shade100.withOpacity(0.1),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(
                height: 60,
                width: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 5,
                  ),
                ),
              ),
            Positioned(
                top: 50,
                right: 10,
                left: 10,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: getWidth(context),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.green,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32))),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              "Here is your rider details: ",
                              style: GoogleFonts.montserrat(
                                  fontSize: 18, color: primaryColor),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(imageUrl +
                                              widget.orderList.driver_photo)),
                                      color: Colors.grey.shade200),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.orderList.driver,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                        const Spacer(),
                                        Text(
                                          widget.orderList.numberPlate,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      widget.orderList.driver_phone,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Driver Location: ",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Expanded(
                                  child: Text(
                                    riderLocation,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                //side: const BorderSide(color: Colors.white)
                              ),
                              color: primaryColor,
                              elevation: 0,
                              child: InkWell(
                                onTap: () => _launchWhatsapp(
                                    widget.orderList.driver_phone),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text(
                                      "Call Rider",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
