import 'dart:async';
import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/helpers/userlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

class Outlets extends StatefulWidget {
  _OutletsState createState() => _OutletsState();
}

class _OutletsState extends State<Outlets> {
  String location = "";
  double latitude = -1.03326;
  double longitude = 37.06933;
  double latitude2 = -1.03326;
  double longitude2 = 37.06933;
  String token = "";
  bool isLoading = true;
  String landmark = '';
  final _customerCodeController = TextEditingController();
  late FToast fToast;
  final Completer<GoogleMapController> _controller = Completer();
  static CameraPosition? _kGooglePlex;
  Map<MarkerId, Marker> markers = {};
  late Position _currentPosition;
  String _currentAddress = '';
  List<RidersList> riderslists = [];

  late ArsProgressDialog progressDialog;

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

    fToast.init(context);
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: const Color(0x33000000),
        animationDuration: const Duration(milliseconds: 500));

    _determinePosition().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
        _kGooglePlex = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 10,
        );
      });

      getaddress();
    });
    fetchoutlets().then((value) {
      setState(() {
        riderslists.addAll(value);
        addmarkers();
      });
    });
  }

  void addmarkers() {
    if (riderslists.length > 0) {
      for (var element in riderslists) {
        print(element.photo);
        _addMarker(
            LatLng(double.parse(element.latitude),
                double.parse(element.longitude)),
            element.id.toString(),
            BitmapDescriptor.defaultMarker,
            element.firstName,
            element.landmark);
      }
    }
  }

  Future<List<RidersList>> fetchoutlets() async {
    final uri = Uri.parse("${mainUrl}outlets");
    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Accept': 'application/json'
    });
    return ridersListFromJson(res.body);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor,
      String name, String location) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: name,
        snippet: location,
      ),
    );
    markers[markerId] = marker;
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
      Geolocator.openLocationSettings();

      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
          _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 10,
          );
        });

        getaddress();
      });
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
          _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 10,
          );
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Outlets Distribution", style: GoogleFonts.montserrat(
                                         color: Colors.white),),
      ),
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
                markers: Set<Marker>.of(markers.values),
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
                bottom: 0,
                right: 0,
                left: 0,
                child: SizedBox(
                    width: getWidth(context),
                    height: 210,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: riderslists.length,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => SizedBox(
                        width: 280,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (riderslists[index].photo != "N/A" &&
                                    riderslists[index].photo != "none" && riderslists[index].photo != null)
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(imageUrl +
                                                riderslists[index].photo))),
                                  )
                                else
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade100),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 0),
                                  child: Text(
                                    riderslists[index].firstName,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(top: 0),
                                  child: Text(
                                    
                                    "${riderslists[index].location} - ${riderslists[index].landmark}",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                                // Row(
                                //   children: [
                                //     Expanded(child: Text(
                                //     "Opposite Mega cly city near thika super highway",
                                //     style: GoogleFonts.montserrat(
                                //         fontSize: 16, fontWeight: FontWeight.bold),
                                //   ),),
                                //   // Card(
                                //   //    shape: RoundedRectangleBorder(
                                //   //     borderRadius: BorderRadius.circular(20)
                                //   //   ),
                                //   //   child: Padding(
                                //   //     padding: const EdgeInsets.all(8.0),
                                //   //     child: Row(
                                //   //       children: [
                                //   //         const Icon(Icons.phone),
                                //   //         Text(
                                //   //           "Call",
                                //   //           style: GoogleFonts.montserrat(
                                //   //               fontSize: 16, fontWeight: FontWeight.bold),
                                //   //         ),
                                //   //       ],
                                //   //     ),
                                //   //   ))
                                //   ],
                                // )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
