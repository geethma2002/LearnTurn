import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM: request permission and get token. Use token for backend to send booking updates.
Future<void> initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  final token = await messaging.getToken();
  if (token != null) {
    // Send token to your backend or Firestore for the current user to receive push notifications
    debugPrint('FCM token: $token');
  }
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground: ${message.notification?.title}');
  });
}

/// Call from main after Firebase.initializeApp (optional).
void setupNotificationHandlers() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background: ${message.notification?.title}');
}
