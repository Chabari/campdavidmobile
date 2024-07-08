import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewLocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<NewLocationPicker> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _determinePosition();
  }

  void _requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
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
      // Permissions are denied forever, handle appropriately.
      _onAlertButtonsPressed(
          'Location permissions are denied. Turn on your location');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _getPlaceName(position.latitude, position.longitude);
    });
  }

  _onAlertButtonsPressed(message) async {
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _currentLocation = position;
    });
  }

  String _placeName = '';

  Future<void> _getPlaceName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _placeName =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<dynamic>> _searchPlace(String input) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&components=country:ke');
    final response = await http.get(
      url,
    );

    return json.decode(response.body)['predictions'];
  }

  Future<void> _selectPlace(String placeId, String placeName) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$kGoogleApiKey');
    final response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body)['result'];
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];

      setState(() {
        _currentLocation = LatLng(lat, lng);
        _placeName = placeName;
      });

      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    } else {  
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 45,
              child: TypeAheadField(
                builder: (context, controller, focusNode) {
                  return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: GoogleFonts.montserrat(fontSize: 20)
                          .copyWith(fontStyle: FontStyle.italic),
                      autofocus: true,
                      decoration: itemDec());
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isNotEmpty) {
                    return await _searchPlace(pattern);
                  } else {
                    return [];
                  }
                },
                itemBuilder: (context, dynamic suggestion) {
                  return ListTile(
                    title: Text(suggestion['description'],
                        style: GoogleFonts.montserrat()),
                  );
                },
                emptyBuilder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Start typing...",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                onSelected: (dynamic suggestion) {
                  if (suggestion != null) {
                    _selectPlace(
                        suggestion['place_id'], suggestion['description']);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation!,
                          zoom: 10,
                        ),
                        onTap: _onTap,
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickedLocation'),
                            position: _currentLocation!,
                          ),
                        },
                      ),
                if (_placeName.isNotEmpty)
                  Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Text(
                                _placeName,
                                style: GoogleFonts.montserrat(fontSize: 15),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: primaryColor,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop({
                                    'current_location': _currentLocation,
                                    'place': _placeName
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(
                                        "Select this Location",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 15, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
