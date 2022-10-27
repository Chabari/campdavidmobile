import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  String from;
  SignupScreen({
    required this.from
  });
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fnameCOntroller = TextEditingController();
  final _lnameCOntroller = TextEditingController();
  final _phoneCOntroller = TextEditingController();
  final _passwordCOntroller = TextEditingController();
  bool obscure = true;
  late ArsProgressDialog progressDialog;
  final _formKey = GlobalKey<FormState>();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: const Color(0x33000000),
        animationDuration: const Duration(milliseconds: 500));
  }

  void validateSubmit() async {
    var formstate = _formKey.currentState;
    if (formstate!.validate()) {
      progressDialog.show();
      var data = {
        'phone': _phoneCOntroller.text,
        'password': _passwordCOntroller.text,
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

      print(response.body);
      Map<String, dynamic> json1 = json.decode(response.body);
      if (response.statusCode == 200) {
        progressDialog.dismiss();
        if (json1['success'] == "1") {
          Map<String, dynamic> user = json1['user'];
          setState(() {
            mpref.setString("token", json1['token']);
            mpref.setString(
                "name", user['first_name'] + " " + user['last_name']);
            mpref.setString("user_id", user['id'].toString());
            mpref.setString("phone", user['phone']);
            mpref.setString("call_phone", json1['call_phone']);
            mpref.setString("support_email", json1['support_email']);
            mpref.setString("orders", json1['orders'].toString());
          });
          _showToast(fToast, json1['message'], Colors.green, Icons.check);
          if(widget.from == "check"){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CheckOutPage(),
              ));

          }else{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPanel(),
              ));

          }
        } else {
          _showToast(fToast, json1['message'], Colors.red, Icons.cancel);
        }
      } else {
        progressDialog.dismiss();
        _showToast(fToast, json1['message'], Colors.red, Icons.cancel);
      }
    }
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
                          height: 20,
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding:
                              const EdgeInsets.all(8.0).copyWith(bottom: 0),
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                size: 30,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            "Signup",
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
                            "Sign up and get started",
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
                      "First Name",
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(10).copyWith(top: 5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      maxLength: 10,
                      onChanged: (value) {},
                      validator: (input) =>
                          input!.isEmpty ? "Firstname should be valid" : null,
                      controller: _fnameCOntroller,
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
                          Icons.person,
                          color: Colors.black87,
                        ),
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        hintText: " Name",
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 18),
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
                    margin: const EdgeInsets.all(10).copyWith(top: 5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      maxLength: 10,
                      onChanged: (value) {},
                      validator: (input) =>
                          input!.isEmpty ? "Last name should be valid" : null,
                      controller: _lnameCOntroller,
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
                          Icons.person,
                          color: Colors.black87,
                        ),
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        hintText: " Name",
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.black87, fontSize: 18),
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
                      maxLength: 10,
                      onChanged: (value) {},
                      validator: (input) =>
                          input!.isEmpty ? "Phone should be valid" : null,
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
                    margin: const EdgeInsets.all(10).copyWith(top: 5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    child: TextFormField(
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obscure,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                      ),
                      onChanged: (value) {},
                      validator: (input) => input!.isEmpty
                          ? "Password should not be empty"
                          : null,
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
                                obscure = !obscure;
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
                  const SizedBox(
                    height: 20,
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
