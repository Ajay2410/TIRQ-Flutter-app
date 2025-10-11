import "dart:convert";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:get/get.dart";
import "package:manager/core/locator.dart";
import "package:manager/routes/routes.dart";
import "package:manager/core/storage/storage.dart";
import "package:stacked_services/stacked_services.dart";

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class FirebaseNotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static var isSound = false;
  static int item = 1;

  static initializeService() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: isSound,
    );
    getNotification();
    item = 1;
    try {
      firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    String? apnsToken = await firebaseMessaging.getAPNSToken();

    apnsToken;
    firebaseMessaging.getToken().then((String? token) async {
      if (token != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          final currentUser = getUser();
          if (currentUser.fcmToken == null) {
            saveUser(currentUser.copyWith(fcmToken: token));
            if (kDebugMode) {
              print("FCM-TOKEN $token");
            }
          } else if (kDebugMode) {
            print("FCM-TOKEN $token");
          }
        });
      }
    });
  }

  static getNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      if (kDebugMode) {
        print(message);
        print("--------------------------${message.data}");
      }
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print(message.data);
      }

      /// NotificationController.to.notificationReadCall(params: {
      ///   ""userid"": ""${getUserDetails().userId}"",
      ///   ""notification_id"": ""${message.data["notification_id"]}""
      /// }, callBack: () {});
      notificationShow(data: message.data);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print(message.data);
    }
    showNotification(message);
  }

  static showNotification(RemoteMessage message) async {
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iOSSettings = const DarwinInitializationSettings();
    var initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    var android = const AndroidNotificationDetails("channel id", "channel NAME", priority: Priority.high, importance: Importance.max);
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    var jsonData = jsonEncode(message.data);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        var payload = notificationResponse.payload;
        if (kDebugMode) {
          print(payload);
        }
        if (payload != null) {
          var jsonData = jsonDecode(payload);
          notificationShow(data: jsonData);
        }
      },
    );

    await flutterLocalNotificationsPlugin.show(
      item++,
      message.notification?.title ?? "",
      message.notification?.body ?? "",
      platform,
      payload: jsonData,
    );
  }

  static notificationShow({data}) async {
    final _navigationService = locator<NavigationService>();

    _navigationService.navigateTo(Routes.notification);

    // String redirectScreen = data["redirectScreen"];
    //
    // switch (redirectScreen) {
    //   case Routes.chatView:
    //     break;
    // }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> init() async {
    await FirebaseNotificationService.initializeService();
  }

  Future<String?> getToken() async {
    String? token = await FirebaseNotificationService.firebaseMessaging.getToken();
    print('FCM Token: $token');
    return token;
  }
}
