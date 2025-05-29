import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MapDeskApp());
}

class MapDeskApp extends StatelessWidget {
  const MapDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // System blue
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
