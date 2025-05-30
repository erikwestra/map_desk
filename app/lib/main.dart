import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'screens/home_screen.dart';
import 'screens/import_screen.dart';
import 'services/database_service.dart';
import 'services/map_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final databaseService = DatabaseService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapService()),
        Provider.value(value: databaseService),
      ],
      child: const MapDeskApp(),
    ),
  );
}

class MapDeskApp extends StatelessWidget {
  const MapDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapDesk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/import': (context) => ImportScreen(
          databaseService: context.read<DatabaseService>(),
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
