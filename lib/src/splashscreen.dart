import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/login.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:campdavid/src/welcomescreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _deviceToken;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) async {
      if (value.getString('device_token') == null) {
        _deviceToken = await FirebaseMessaging.instance.getToken();
        value.setString('device_token', _deviceToken);
      }
      if (value.getBool('isFirst') == null) {
        Future.delayed(const Duration(seconds: 3)).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ));
        });
      } else {
        if (value.getString('user_id') != null) {
          getuser(value.getString('token'), value.getString('user_id'));
        } else {
          // getversion();
          Future.delayed(const Duration(seconds: 3)).then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPanel(),
                ));
          });
        }
      }
    });
  }

  void getuser(token, userId) async {
    _deviceToken = await FirebaseMessaging.instance.getToken();
    var data = {'user_id': userId, 'token': _deviceToken};
    var body = json.encode(data);
    var response = await http.post(Uri.parse("${mainUrl}check-refresh"),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json'
        },
        body: body);
    final mpref = await SharedPreferences.getInstance();
    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      if (json1['success'] == "1") {
        Map<String, dynamic> user = json1['user'];
        setState(() {
          mpref.setString("token", json1['token']);
          if (json1['kGoogleApiKey'] != null) {
            kGoogleApiKey = json1['kGoogleApiKey'];
          }
          mpref.setString("name", user['first_name'] + " " + user['last_name']);
          mpref.setString("user_id", user['id'].toString());
          if (user['location'] != null) {
            mpref.setString("location", user['location']);
          }
          mpref.setString("phone", user['phone']);
          mpref.setString("call_phone", json1['call_phone']);
          mpref.setString("support_email", json1['support_email']);
          mpref.setString("paybill", json1['paybill']);
          mpref.setString("orders", json1['orders'].toString());
          mpref.setString("version", json1['version'].toString());
        });

        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPanel(),
              ));
        });
      } else {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(from: "main"),
              ));
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(from: "main"),
            ));
      });
    }
  }

  void getversion() async {
    var response = await http.get(
      Uri.parse("${mainUrl}check-version"),
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json'
      },
    );
    final mpref = await SharedPreferences.getInstance();
    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      mpref.setString("version", json1['version'].toString());
      Future.delayed(const Duration(seconds: 1)).then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPanel(),
            ));
      });
    } else {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPanel(),
            ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
          color: Colors.white,
          height: getHeight(context),
          width: getWidth(context),
          child: SafeArea(
              child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                    margin: const EdgeInsets.only(bottom: 100),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/camp.png"))),
                  ),
                ],
              ),
              const Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 5,
                      ),
                    ),
                  ))
            ],
          ))),
    );
  }
}
