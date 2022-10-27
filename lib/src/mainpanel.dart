import 'package:campdavid/helpers/cartmodel.dart';
import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/cartpage.dart';
import 'package:campdavid/src/category.dart';
import 'package:campdavid/src/home.dart';
import 'package:campdavid/src/searchpage.dart';
import 'package:campdavid/src/useraccount.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _db.getAllCarts().then((scans) {
      setState(() {
        ordersList.addAll(scans);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          _controller.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
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

              // Container(
              //   margin: const EdgeInsets.only(left: 8),
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [

              //           Expanded(
              //             child: InkWell(
              //               onTap: () {
              //               },
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.start,
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     "DELIVER TO.",
              //                     style: GoogleFonts.montserrat(
              //                       color: Colors.grey,
              //                       fontSize: 18,
              //                     ),

              //                   ),
              //                   Text(
              //                     "Kindly provide us with your home location",
              //                         maxLines: 1,
              //                         overflow: TextOverflow.ellipsis,
              //                     style: GoogleFonts.montserrat(
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold,
              //                       fontSize: 18,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           InkWell(
              //             onTap: () {
              //             },
              //             child: Container(
              //                 margin: const EdgeInsets.only(right: 20),
              //                 alignment: Alignment.topCenter,
              //                 child: const Icon(
              //                   Icons.arrow_drop_down_outlined,
              //                   size: 40,
              //                   color:primaryColor,
              //                 )),
              //           )
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

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
                      CartPage(),
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
