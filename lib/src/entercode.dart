import 'dart:async';
import 'dart:convert';
import 'package:campdavid/src/setpassword.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../helpers/constants.dart';

class PhoneVerification extends StatefulWidget {
  late String phone;
  PhoneVerification({required this.phone});

  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  TextEditingController textEditingController = TextEditingController();
  StreamConsumer<ErrorAnimationType>? errorController;

  bool hasError = false;
  bool enabled = false;
  var _deviceToken;
  late FToast fToast;

  late ProgressDialog progressDialog;
  late SharedPreferences mprefs;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    
    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: false);
    errorController = StreamController<ErrorAnimationType>();

    SharedPreferences.getInstance().then((value) {
      mprefs = value;
    });
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  void validatephone() async {
    await progressDialog.show();

    var data = {'code': textEditingController.text};
    var body = json.encode(data);
    var response = await http.post(Uri.parse("${mainUrl}verifyPhone"),
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
                builder: (context) => SetPassword(phone: widget.phone),
              ));
        }
      } else {
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

  void validateresend() async {
   await progressDialog.show();
    var data = {'phone': widget.phone};
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
        }
      } else {
        _showToast(fToast, json1['message'], Colors.red, Icons.cancel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.height;
    // TODO: implement build

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 45, left: 8),
                child: Icon(
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child: Image.asset("assets/images/camp.png"),
                ),
                Text(
                  "Camp David",
                  style: GoogleFonts.montserrat(
                      fontSize: 30,
                      color: primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "You're Almost there",
              style:
                  GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            
            SizedBox(
              height: height * 0.1,
            ),
            Container(
              margin: const EdgeInsets.all(10).copyWith(bottom: 0),
              child: PinCodeTextField(
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                obscuringWidget: Image.asset("assets/images/camp.png"),
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                backgroundColor: Colors.white,
                validator: (v) {
                  if (v!.length < 3) {
                    return "Riel validation";
                  } else {
                    return null;
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  selectedFillColor: Colors.grey,
                  selectedColor: Colors.white,
                  inactiveColor: Colors.black54,
                  inactiveFillColor: Colors.white,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  activeColor: Colors.white,
                ),
                cursorColor: Colors.black,
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                // errorAnimationController: errorController,
                controller: textEditingController,
                keyboardType: TextInputType.number,
                boxShadows: const [
                   BoxShadow(
                    offset: Offset(0, 1),
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
                onCompleted: (v) {
                  setState(() {
                    enabled = true;
                  });
                  validatephone();
                },
                // onTap: () {
                //   print("Pressed");
                // },
                onChanged: (value) {
                  setState(() {
                    // currentText = value;
                  });
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ),
            ),

            // SizedBox(height: height * 0.008,),
            Container(
              margin: EdgeInsets.all(8).copyWith(bottom: 0, top: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Input verification code sent to ",
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    widget.phone,
                    style: GoogleFonts.cabin(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8).copyWith(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "(Didn't Receive Code? ) ",
                    style: GoogleFonts.cabin(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,),
                  ),
                  InkWell(
                      onTap: () {
                        validateresend();
                      },
                      child: Text(
                        " VERIFY",
                        style: GoogleFonts.cabin( fontSize: 18),
                      ))
                ],
              ),
            ),
            SizedBox(
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
                  validatephone();
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
          ],
        ),
      ),
    );
  }
}
