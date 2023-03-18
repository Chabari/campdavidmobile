import 'package:campdavid/helpers/constants.dart';
import 'package:campdavid/src/login.dart';
import 'package:campdavid/src/mainpanel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0,);

  List<AllinOnboardModel> allinonboardlist = [
    AllinOnboardModel(
        "assets/images/designf.jpg",
        "Welcome to Camp David Butchery. We offer premium quality meat, our first priority to our customers. It has already stood the test of time! Butchery is the art of selecting, slaughtering, deboning, cutting and preparing meat and as Camp David butchery we have worked on perfecting this art to serve our customers in the best way possible.",
        "Prepard by exparts"),
    AllinOnboardModel(
        "assets/images/designs.jpg",
        "This technique is used to extend the timeliness of the fresh meat but still maintaining its quality under storage.All our deliveries are sealed to our customers desires in terms of portions for easy storage, hygiene, maintaining meat taste while avoiding food poisoning and fridge burns. Make your order, instruct us how we should package your meat and let us do the magic .",
        "Vacuum packaging meat"),
    AllinOnboardModel(
        "assets/images/designt.jpg",
        "Shop online and get it delivered to your door step. We serve nothing but the best.Online deliveries are one of the ways technology has served us in this digital era.With just a few clicks, you make your order, and have it delivered to your desired location.",
        "Delivery"),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    SharedPreferences.getInstance().then((value) {
      value.setBool('isFirst', false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                itemCount: allinonboardlist.length,
                itemBuilder: (context, index) {
                  return PageBuilderWidget(
                      title: allinonboardlist[index].titlestr,
                      description: allinonboardlist[index].description,
                      imgurl: allinonboardlist[index].imgStr);
                }),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.10,
              left: MediaQuery.of(context).size.width * 0.44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allinonboardlist.length,
                  (index) => buildDot(index: index),
                ),
              ),
            ),
            currentIndex < allinonboardlist.length - 1
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (currentIndex > -1) {
                              if (currentIndex == 0) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainPanel(),
                                  ));
                              } else {
                                setState(() {
                                  currentIndex--;

                                  _pageController.animateToPage(currentIndex,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.easeOut);
                                });
                              }
                            }
                          },
                          child: Text(
                            currentIndex == 0 ? "Skip" : "Previous",
                            style: GoogleFonts.montserrat(
                                fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: primaryColor,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0))),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (currentIndex < 3) {
                              setState(() {
                                currentIndex++;

                                _pageController.animateToPage(currentIndex,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeOut);
                              });
                            }
                          },
                          child: Text(
                            "Next",
                            style: GoogleFonts.montserrat(
                                fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: primaryColor,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0))),
                          ),
                        )
                      ],
                    ),
                  )
                : Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.15,
                    left: MediaQuery.of(context).size.width * 0.33,
                    child: ElevatedButton(
                      onPressed: () {
                       Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainPanel(),
                                  ));
                      },
                      child: Text(
                        "Get Started",
                        style: GoogleFonts.montserrat(
                            fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                    ),
                  ),
            if (currentIndex != 0)
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {
                  Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainPanel(),
                                  ));
                },
                  child: Text(
                          "Skip",
                          style: GoogleFonts.montserrat(
                              fontSize: 20, color: primaryColor,),
                        ),
                ))
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentIndex == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? primarygreen : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  String title;
  String description;
  String imgurl;
  PageBuilderWidget(
      {Key? key,
      required this.title,
      required this.description,
      required this.imgurl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            child: Image.asset(imgurl),
          ),
          const SizedBox(
            height: 20,
          ),
          //Tite Text
          Text(title,
              style: GoogleFonts.montserrat(
                  color: primarygreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const SizedBox(
            height: 20,
          ),
          //discription
          Text(description,
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                color: primarygreen,
                fontSize: 14,
              ))
        ],
      ),
    );
  }
}

class AllinOnboardModel {
  String imgStr;
  String description;
  String titlestr;
  AllinOnboardModel(this.imgStr, this.description, this.titlestr);
}
