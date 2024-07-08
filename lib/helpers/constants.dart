import 'package:campdavid/helpers/cartmodel.dart';
import 'package:campdavid/helpers/productscontroller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const Color lightgreenshede = Color(0xFFF0FAF6);
const Color lightgreenshede1 = Color(0xFFB2D9CC);
const Color greenshede0 = Color(0xFF66A690);
const Color greenshede1 = Color(0xFF93C9B5);
const Color primarygreen = Color(0xFF1E3A34);
const Color grayshade = Color(0xFF93B3AA);
const Color colorAcent = Color(0xFF78C2A7);
const Color cyanColor = Color(0xFF6D7E6E);
const Color primaryColor = Color(0xFFd01f3a);
const Color secondaryColor = Color(0xFF961a1d);
const Color bgColor = Color(0xFFedeef9);
const Color backGround = Color(0xFFe58e9b);

final productCtl = Get.find<ProductController>();

String kGoogleApiKey = "AIzaSyAm41IGdUL9e0wiPYhW_m0PtdiD069PwLU";

const mainUrl = "https://delivery.campdavidbutchery.com/api/";
const imageUrl = "https://delivery.campdavidbutchery.com/storage/";

// const mainUrl = "http://192.168.0.105/api/";
// const imageUrl = "http://192.168.0.105/storage/";

const kAnimationDuration = Duration(milliseconds: 200);

double getHeight(context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(context) {
  return MediaQuery.of(context).size.height;
}

String getdatedate(DateTime dat) {
  String formated = DateFormat('dd-MM-yyyy').format(dat).toString();
  return formated;
}

String getdatedatetime(DateTime dat) {
  String formated = DateFormat('dd-MM-yyyy HH:mm a').format(dat).toString();
  return formated;
}

bool getElement(List<OrderItemsModel> items, id) {
  bool isItem = false;
  items.forEach((element) {
    if (element.productId == id) {
      isItem = true;
    }
  });
  return isItem;
}

String getdatestringformat(String date) {
  DateTime dat = DateTime.parse(date);
  if (dat.day == DateTime.now().day && dat.month == DateTime.now().month) {
    return "Today";
  }
  String formated = DateFormat.MMMd().format(dat).toString();

  return formated;
}

InputDecoration itemDec() {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(8),
    hintText: "Search location",
    hintStyle: GoogleFonts.montserrat(fontSize: 20).copyWith(
      color: Colors.black.withOpacity(0.5),
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(
      Icons.search,
      color: Colors.black.withOpacity(0.5),
    ),
  );
}
