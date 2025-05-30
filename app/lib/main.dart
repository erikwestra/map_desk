// Main entry point for MapDesk that sets up the app's providers and navigation structure.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'screens/home_screen.dart';
import 'screens/import_screen.dart';
import 'services/map_service.dart';
import 'services/import_service.dart';
import 'services/view_service.dart';
import 'services/database_service.dart';
import 'services/gpx_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MapDeskApp());
}

class MapDeskApp extends StatelessWidget {
  const MapDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProvider(create: (_) => ImportService()),
        ChangeNotifierProvider(create: (_) => ViewService()),
        Provider(create: (_) => DatabaseService()),
        Provider(create: (_) => GpxService()),
      ],
      child: MaterialApp(
        title: 'MapDesk',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        routes: {
          '/import': (context) => const ImportScreen(),
        },
      ),
    );
  }
}
