import 'package:flutter/material.dart';
import 'package:monitorph/views/mainview.dart';

class PHMonitorApp extends StatelessWidget {
  const PHMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainView(),
    );
  }
}
