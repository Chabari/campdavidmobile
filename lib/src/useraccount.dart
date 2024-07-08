import 'dart:convert';

import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/aboutus.dart';
import 'package:campdavid/src/editprofile.dart';
import 'package:campdavid/src/login.dart';
import 'package:campdavid/src/orderspage.dart';
import 'package:campdavid/src/resetpasword.dart';
import 'package:campdavid/src/returnpolicy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class UserAccount extends StatefulWidget {
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  bool selected = false;
  String call_phone = "0714532554";
  String support_email = "info@campdavidbutchery.com";
  String token = "";
  String name = "";
  String phone = "";
  String orders = "0";
  bool isLoggedIn = false;
  late SharedPreferences mprefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) {
      mprefs = value;
      if (mprefs.getString('token') != null) {
        getuser(value.getString('token'), value.getString('user_id'));
        setState(() {
          isLoggedIn = true;
          token = mprefs.getString('token')!;
          name = mprefs.getString('name')!;
          phone = mprefs.getString('phone')!;
          orders = mprefs.getString('orders')!;
          call_phone = mprefs.getString('call_phone')!;
          support_email = mprefs.getString('support_email')!;
        });
      }
    });
  }

  _launchWhatsapp(action) async {
    var whatsappAndroid = Uri();

    whatsappAndroid = Uri.parse("tel:$call_phone");

    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }

  _sendMail() async {
    var uri1 = 'mailto:$support_email?subject=Greetings&body=Hello';
    var uri = Uri.parse(uri1);
    try {
      await canLaunchUrl(uri);
      await launchUrl(uri);
    } on Exception catch (exception) {
      print(exception.toString());
    } catch (error) {
      print(error.toString());
    }
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
    Map<String, dynamic> json1 = json.decode(response.body);
    final mpref = await SharedPreferences.getInstance();
    if (response.statusCode == 200) {
      Map<String, dynamic> user = json1['user'];
      if (json1['success'] == "1") {
        if (mounted) {
          setState(() {
            orders = json1['orders'].toString();
            mpref.setString(
                "name", user['first_name'] + " " + user['last_name']);
            mpref.setString("phone", user['phone']);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          if (isLoggedIn)
            Text(
              name,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
          if (isLoggedIn)
            Text(
              phone,
              style: GoogleFonts.montserrat(
                color: Colors.grey,
              ),
            ),
          const SizedBox(
            height: 8,
          ),
          if (isLoggedIn)
            Center(
              child: SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: primaryColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Edit Profile",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_circle_right_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Center(
              child: SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(from: "main"),
                        ));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: primaryColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login/Signup",
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
          const SizedBox(
            height: 20,
          ),
          if (isLoggedIn)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              margin: const EdgeInsets.all(4),
              child: ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersPage(),
                    )),
                leading: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      "Orders",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          orders,
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
                subtitle: Text(
                  "View and manage orders",
                  style:
                      GoogleFonts.montserrat(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_outlined),
              ),
            ),
          if (isLoggedIn)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              margin: const EdgeInsets.all(4),
              child: ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPassword(phone: ""),
                    )),
                leading: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(
                    Icons.password,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  "Reset Password",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                  "Manage your account password",
                  style:
                      GoogleFonts.montserrat(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_outlined),
              ),
            ),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.all(4),
            child: ListTile(
              onTap: () {
                setState(() {
                  selected = !selected;
                });
              },
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.help,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Help & Support",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: selected
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Get help from our Customer center",
                          style: GoogleFonts.montserrat(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        InkWell(
                          onTap: () => _sendMail(),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              const Icon(
                                Icons.email,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("Email: ",
                                  style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              Text(support_email,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        InkWell(
                          onTap: () => _launchWhatsapp('c'),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              const Icon(
                                Icons.phone_in_talk,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("Call Us: ",
                                  style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              Text(call_phone,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        )
                      ],
                    )
                  : Text(
                      "Get help from our Customer center",
                      style: GoogleFonts.montserrat(
                          color: Colors.grey, fontSize: 12),
                    ),
              trailing: selected
                  ? const Icon(Icons.arrow_drop_down_rounded)
                  : const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.all(4),
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUs(),
                  )),
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.more,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "About Us",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text(
                "View more details about Camp David",
                style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.all(4),
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnPolicy(),
                  )),
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.policy,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Return Policy",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text(
                "View our return policy here",
                style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (isLoggedIn)
            ClipPath(
              clipper: MovieTicketBothSidesClipper(),
              child: Container(
                height: 100,
                color: Colors.grey.shade300,
                child: Center(
                  child: SizedBox(
                    width: 150,
                    child: InkWell(
                      onTap: () {
                        mprefs.clear().then((value) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(from: "me"),
                              ));
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: primaryColor,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Logout",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
