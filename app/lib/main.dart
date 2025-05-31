// Main entry point for MapDesk that sets up the app's providers and navigation structure.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/mode_service.dart';
import 'core/services/database_service.dart';
import 'core/services/gpx_service.dart';
import 'modes/map/services/map_service.dart';
import 'modes/import_track/services/import_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModeService()),
        Provider(create: (_) => DatabaseService()),
        Provider(create: (_) => GpxService()),
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProvider(create: (_) => ImportService()),
      ],
      child: MaterialApp(
        title: 'MapDesk',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
