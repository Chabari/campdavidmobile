import 'dart:convert';

import 'package:ars_progress_dialog/dialog.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  _EditProfileState createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile> {
  late SharedPreferences mprefs;
  late ArsProgressDialog progressDialog;
  late FToast fToast;
  final _formKey = GlobalKey<FormState>();
  final _phoneCOntroller = TextEditingController();
  final _fnameCOntroller = TextEditingController();
  final _lnameCOntroller = TextEditingController();
  final _homeLocationCOntroller = TextEditingController();
  final _addressCOntroller = TextEditingController();

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
      mprefs = value;
      if (mprefs.getString('token') != null) {
        getuser(value.getString('token'), value.getString('user_id'));
        setState(() {
          // isLoggedIn = true;
          // token = mprefs.getString('token')!;
          // name = mprefs.getString('name')!;
          // phone = mprefs.getString('phone')!;
          // orders = mprefs.getString('orders')!;
          // call_phone = mprefs.getString('call_phone')!;
          // support_email = mprefs.getString('support_email')!;
        });
      }
    });
  }


  void getuser(token, userId) async {
    var data = {'user_id': userId};
    var body = json.encode(data);
    var response = await http.post(Uri.parse("${mainUrl}check-refresh"),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json'
        },
        body: body);
    print(response.body);
    Map<String, dynamic> json1 = json.decode(response.body);
    if (response.statusCode == 200) {
      if (json1['success'] == "1") {
        setState(() {
          // orders = json1['orders'].toString();
        });
      } else {
        
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

  void validateSubmit() async {
    var formstate = _formKey.currentState;
    if (formstate!.validate()) {
      progressDialog.show();
      var data = {
        'password': _addressCOntroller.text,
        'phone': _phoneCOntroller.text
      };
      var body = json.encode(data);
      print(body);
      var response = await http.post(Uri.parse("${mainUrl}user-signin"),
          headers: {
            "Content-Type": "application/json",
            'Accept': 'application/json',
          },
          body: body);
      final mpref = await SharedPreferences.getInstance();

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
          if (mounted) {
            _showToast(fToast, json1['message'], Colors.green, Icons.check);
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



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: SafeArea(child: Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 30, color: Colors.white,)),
                const SizedBox(width: 10,),
                Text(
                  "Edit User Profile",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                color: Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Name",
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: "eg John Doe",
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
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Home Location",
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: "eg Nairobi",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Nearest Landmark",
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
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.location_history_rounded,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: " Landmark",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
              height: 100,
              child: Center(
                child: SizedBox(
                  width: getWidth(context),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: primaryColor,
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Submit",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                  ),
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
