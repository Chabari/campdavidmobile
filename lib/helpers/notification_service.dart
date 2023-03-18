import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {
  NotificationHelper();

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidInitialize =
        AndroidInitializationSettings('notification_icon');
    final initializationsSettings =
        const InitializationSettings(android: androidInitialize);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "onMessage: ${message.notification!.title}/${message.notification!.body}");
      NotificationHelper.showNotification(
          message, flutterLocalNotificationsPlugin, false);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        print("ziiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
      } catch (e) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    String title;
    String body;
    if (data) {
      title = message.data['title'];
      body = message.data['body'];
    } else {
      title = message.notification!.title!;
      body = message.notification!.body!;
    }

    await showTextNotification(title, body, message, fln);
  }

  static Future<void> showTextNotification(String title, String body,
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'campdavid',
      'campdavidname',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      icon: 'notification_icon',
      actions: [],
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  static Future<void> showBigTextNotification(
      String title, String body, FlutterLocalNotificationsPlugin fln) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'riel channel id',
      'riel name',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String title,
      String body, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'riel',
      'riel name',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  var androidInitialize =
      const AndroidInitializationSettings('notification_icon');
  var initializationsSettings =
      InitializationSettings(android: androidInitialize);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  NotificationHelper.showNotification(
      message, flutterLocalNotificationsPlugin, true);
}
