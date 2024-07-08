import 'package:campdavid/src/mainpanel.dart';
import 'package:campdavid/src/productdetails.dart';
import 'package:campdavid/src/productspage.dart';
import 'package:campdavid/src/promotiondetails.dart';
import 'package:campdavid/src/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'helpers/categorycontroller.dart';
import 'helpers/homecontroller.dart';
import 'helpers/notification_service.dart';
import 'helpers/productscontroller.dart';
import 'helpers/searchpagecontroller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initdependencies();
  // ignore: deprecated_member_use
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  int? _orderID;

  try {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      String? selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
    }
    final RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      _orderID = remoteMessage.notification!.titleLocKey != null
          ? int.parse(remoteMessage.notification!.titleLocKey!)
          : null;
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {}

  runApp(MyApp());
}

Future initdependencies() async {
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => CategoryController(), fenix: true);
  Get.lazyPut(() => ProductController(), fenix: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: true,
      initialRoute: '/splash',
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(
            name: '/products',
            page: () => const ProductsPage(),
            customTransition: SizeTransitions()),
        GetPage(
            name: '/promotion-details',
            page: () => const PromotionDetails(),
            customTransition: SizeTransitions()),
        GetPage(
            name: '/products-details',
            page: () => const ProductDetails(),
            customTransition: SizeTransitions()),
        GetPage(
            name: '/main-panel',
            page: () => MainPanel(),
            customTransition: SizeTransitions()),
      ],
    );
  }
}

class SizeTransitions extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return Align(
      alignment: Alignment.center,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animation,
          curve: curve!,
        ),
        child: child,
      ),
    );
  }
}
