// Main entry point for MapDesk that sets up the app's providers and navigation structure.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/services/mode_service.dart';
import 'core/services/database_service.dart';
import 'core/services/gpx_service.dart';
import 'core/services/segment_service.dart';
import 'modes/map/services/map_service.dart';
import 'modes/import_track/services/import_service.dart';
import 'modes/segment_library/services/segment_library_service.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialize FFI for desktop platforms
  sqfliteFfiInit();
  // Change the default factory for desktop platforms
  databaseFactory = databaseFactoryFfi;
  
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
        Provider(
          create: (context) => SegmentService(
            context.read<DatabaseService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProvider(
          create: (context) => ImportService(
            context.read<SegmentService>(),
          ),
        ),
        Provider(
          create: (context) => SegmentLibraryService(
            context.read<SegmentService>(),
          ),
        ),
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
