import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/entercode.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  String phone;
  ResetPassword({required this.phone});
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _phoneCOntroller = TextEditingController();
  late ProgressDialog progressDialog;
  late SharedPreferences mprefs;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    if (widget.phone != "") {
      setState(() {
        _phoneCOntroller.text = widget.phone;
      });
    }
    
    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);
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

  void validateSubmit() async {
    if (_phoneCOntroller.text.isNotEmpty) {
      await progressDialog.show();
      var data = {'phone': _phoneCOntroller.text};
      var body = json.encode(data);
      var response = await http.post(Uri.parse("${mainUrl}sendVerification"),
          headers: {
            "Content-Type": "application/json",
            'Accept': 'application/json',
          },
          body: body);

      Map<String, dynamic> json1 = json.decode(response.body);
      if (response.statusCode == 200) {
       await progressDialog.hide();
        if (json1['success'] == "1") {
          if (mounted) {
            _showToast(fToast, json1['message'], Colors.green, Icons.check);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PhoneVerification(phone: _phoneCOntroller.text),
                ));
          }
        } else {
          _showToast(fToast, json1['message'], Colors.red, Icons.cancel);
        }
      }
    } else {
      _showToast(fToast, "Enter phone number", Colors.red, Icons.cancel);
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 170,
                  width: getWidth(context),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(60))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 30,
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Reset Password",
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
                          "Provide Phone Number. You will receive password recovery code",
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
                    maxLength: 10,
                    onChanged: (value) {},
                    controller: _phoneCOntroller,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
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
                      //       Navigator.pushReplacement(
                      // context,
                      // MaterialPageRoute(
                      //   builder: (context) =>
                      //       PhoneVerification(phone: _phoneCOntroller.text),
                      // ));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "RESET",
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
    );
  }
}
