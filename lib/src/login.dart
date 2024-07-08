import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:campdavid/src/resetpasword.dart';
import 'package:campdavid/src/setpassword.dart';
import 'package:campdavid/src/signup.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  String from;
  LoginScreen({required this.from});
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCOntroller = TextEditingController();
  final _passwordCOntroller = TextEditingController();
  bool obscure = true;
  late ProgressDialog progressDialog;
  late FToast fToast;
  var _deviceToken;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences mprefs;

  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);

    // SharedPreferences.getInstance().then((value) {
    //   if (value.getString('token') != null) {
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => MainPanel(),
    //         ));
    //   }
    // });_formKey
  }

  void validateSubmit() async {
    var formstate = _formKey.currentState;
    _deviceToken = await FirebaseMessaging.instance.getToken();
    if (formstate!.validate()) {
      await progressDialog.show();
      var data = {
        'password': _passwordCOntroller.text,
        'phone': _phoneCOntroller.text,
        'token': _deviceToken
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
        await progressDialog.hide();
        if (json1['success'] == "1") {
          Map<String, dynamic> user = json1['user'];
          setState(() {
            mpref.setString("token", json1['token']);
            if (json1['kGoogleApiKey'] != null) {
              kGoogleApiKey = json1['kGoogleApiKey'];
            }
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
            showtoast(json1['message'], Colors.green);
          }
          if (widget.from == "check") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckOutPage(),
                ));
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPanel(),
                ));
          }
        } else if (json1['success'] == "2") {
          _onAlertButtonsPressed(context, json1['message']);
        } else {
          showtoast(json1['message'], Colors.red);
        }
      } else {
        await progressDialog.hide();
        showtoast(json1['message'], Colors.red);
      }
    }
  }

  void showtoast(message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _onAlertButtonsPressed(context, message) {
    Alert(
      context: context,
      type: AlertType.warning,
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: GoogleFonts.lato(
            color: primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
        descStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 18),
      ),
      title: "Failed!",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "CANCEL",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        DialogButton(
          child: Text(
            "SET",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SetPassword(phone: _phoneCOntroller.text),
                ));
          },
          gradient: const LinearGradient(colors: [
            secondaryColor,
            primaryColor,
          ]),
        )
      ],
    ).show();
  
  
  }

  _showToast(fToast, message, color, icon) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 16.0,
            left: 16.0,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        height: getHeight(context),
        width: getWidth(context),
        color: bgColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 170,
                    width: getWidth(context),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(60))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            "Login",
                            style: GoogleFonts.montserrat(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            "Sign in and get started",
                            style: GoogleFonts.montserrat(),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      maxLength: 13,
                      onChanged: (value) {},
                      controller: _phoneCOntroller,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
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
                            color: Colors.black87, fontSize: 18),
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
                    margin: const EdgeInsets.all(10).copyWith(top: 5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: isObscure,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      onChanged: (value) {},
                      controller: _passwordCOntroller,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32))),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32))),
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        prefixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            child: const Icon(
                              Icons.password,
                              color: Colors.black87,
                            )),
                        hintText: "Password",
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 18),
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
                        validateSubmit();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPassword(phone: ""),
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
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignupScreen(from: widget.from),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an Account? ",
                            style: GoogleFonts.montserrat(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                          // SizedBox(width: 3,),
                          Text(
                            "Sign Up",
                            style: GoogleFonts.montserrat(
                              color: primaryColor,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
