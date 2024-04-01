import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitorph/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAuResZ3yDUAyuVY1RIe_NoWNOsAhaxR84',
      appId: '1:1089540674888:android:d94c7f8c2338c760234f7d',
      messagingSenderId: '1089540674888',
      projectId: 'ph-monitor-app',
      databaseURL:
          "https://ph-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ),
  );
  sqfliteFfiInit();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveLocalNotification);

  runApp(const PHMonitorApp());
}

void onDidReceiveLocalNotification(NotificationResponse res) {
  print('id ${res.id}');
}

void selectNotification(String? payload) {
  if (payload != null && payload.isNotEmpty) {}
}
