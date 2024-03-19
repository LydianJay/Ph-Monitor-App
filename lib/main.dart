import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:monitorph/app.dart';

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
  runApp(const PHMonitorApp());
}
