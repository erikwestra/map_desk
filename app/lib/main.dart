import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/map_service.dart';
import 'services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service
  final databaseService = DatabaseService();
  
  runApp(MapDeskApp(databaseService: databaseService));
}

class MapDeskApp extends StatelessWidget {
  final DatabaseService databaseService;
  
  const MapDeskApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapService()),
        Provider<DatabaseService>.value(value: databaseService),
      ],
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
