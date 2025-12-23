import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message, true);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _handleMessage(RemoteMessage message, bool isForeground) async {
    final notification = {
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'url': message.data['url'] ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('notification_history') ?? [];
    history.insert(0, jsonEncode(notification));
    await prefs.setStringList('notification_history', history);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final fcmService = FcmService();
  await fcmService._handleMessage(message, false);
}
