import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class DevicetokenController extends GetxController {
  RxString deviceToken = ''.obs;

  Future<void> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      //  Request notification permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log(" Notification permission denied", name: 'DevicetokenController');
        return;
      }

      //  Get the Firebase Cloud Messaging token
      final String? token = await messaging.getToken();
      if (token != null) {
        deviceToken.value = token;
        log(' FCM Token: $token', name: 'DevicetokenController');
      } else {
        log(" Failed to get FCM token", name: 'DevicetokenController');
      }
    } catch (e) {
      log(' Error fetching FCM token: $e', name: 'DevicetokenController');
    }
  }
}
