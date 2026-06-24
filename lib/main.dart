import 'package:flutter/material.dart';
import 'package:mo/features/auth/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analyze Game AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1129A4)),
        useMaterial3: true,
      ),
      home: const GameAnalyzeWelcomeScreen(),
    );
  }
}
