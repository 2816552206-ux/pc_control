import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PcControlApp());
}

class PcControlApp extends StatelessWidget {
  const PcControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '远程开机控制',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
