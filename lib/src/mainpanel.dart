import 'dart:async';

import 'package:campdavid/helpers/cartmodel.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/cartpage.dart';
import 'package:campdavid/src/category.dart';
import 'package:campdavid/src/checkout.dart';
import 'package:campdavid/src/home.dart';
import 'package:campdavid/src/searchpage.dart';
import 'package:campdavid/src/useraccount.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';

import '../helpers/databaseHelper.dart';

class MainPanel extends StatefulWidget {
  _MainPanelState createState() => _MainPanelState();
}

class _MainPanelState extends State<MainPanel> {
  final PageController _controller = PageController(initialPage: 0);

  List<OrderItemsModel> ordersList = [];
  final DBHelper _db = DBHelper();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  AppUpdateInfo? _updateInfo;

  bool flexibleUpdateAvailable = false;

  void deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        deleteCacheDir();

        InAppUpdate.performImmediateUpdate().then((_) {
          setState(() {
            flexibleUpdateAvailable = true;
          });
        }).catchError((e) {
          showSnack(e.toString());
        });
      }
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList = scans;
      });
    });

    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (mounted) {
        _db.getAllCarts().then((scans) {
          setState(() {
            ordersList = scans;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        Text(
                          "What would you like to buy today?",
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(
                      width: 30,
                    ),
                    // const Icon(Icons.favorite_border,
                    //     color: Colors.white, size: 30),
                    InkWell(
                        onTap: () {
                          // _controller.animateToPage(
                          //   2,
                          //   duration: const Duration(milliseconds: 400),
                          //   curve: Curves.easeOut,
                          // );
                          if (ordersList.length > 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckOutPage(),
                                ));
                          } else {
                            Fluttertoast.showToast(
                                msg: "Failed. Please add something to cart",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                        child: Stack(
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: Colors.white, size: 30),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    ordersList.length.toString(),
                                    style: GoogleFonts.montserrat(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                          ],
                        ))
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(),
                        ));
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 35,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Search in Camp David..",
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32))),
                  child: PageView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Home(
                        screen: (index) {
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        fetch: (fet) {
                          if (fet) {
                            ordersList.clear();
                            _db.getAllCarts().then((value2) {
                              setState(() {
                                ordersList.addAll(value2);
                              });
                            });
                          }
                        },
                      ),
                      Category(fetch: (fet) {
                        if (fet) {
                          ordersList.clear();
                          _db.getAllCarts().then((value2) {
                            setState(() {
                              ordersList.addAll(value2);
                            });
                          });
                        }
                      }),
                      CartPage(
                        screen: (index) {
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      UserAccount(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: RollingBottomBar(
          color: Colors.white,
          controller: _controller,
          items: const [
            RollingBottomBarItem(
              Icons.home,
              label: 'Home',
            ),
            RollingBottomBarItem(Icons.category, label: 'Explore'),
            RollingBottomBarItem(Icons.shopping_cart_outlined, label: 'Cart'),
            RollingBottomBarItem(Icons.person, label: 'Account'),
          ],
          activeItemColor: Colors.green.shade700,
          enableIconRotation: true,
          onTap: (index) {
            _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
        ),
      ),
    );
  }
}
