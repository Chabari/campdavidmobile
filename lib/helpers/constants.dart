import 'package:campdavid/helpers/cartmodel.dart';
import 'package:flutter/cupertino.dart';
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


const kGoogleApiKey = "AIzaSyCUwQCkzVToSTN9PCH2KKuIO9MjCBzS1as";

const mainUrl = "https://campdavid.silverbridge.co.ke/api/";
const imageUrl = "https://campdavid.silverbridge.co.ke/storage/";

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
