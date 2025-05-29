import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/map_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MapDeskApp());
}

class MapDeskApp extends StatelessWidget {
  const MapDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapService(),
      child: MaterialApp(
        title: 'MapDesk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF), // System blue
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
