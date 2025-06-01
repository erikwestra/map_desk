// Main entry point for MapDesk that sets up the app's providers and navigation structure.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/services/mode_service.dart';
import 'core/services/database_service.dart';
import 'core/services/gpx_service.dart';
import 'core/services/segment_service.dart';
import 'modes/map/services/map_service.dart';
import 'modes/import_track/services/import_service.dart';
import 'modes/segment_library/services/segment_library_service.dart';
import 'modes/route_builder/models/route_builder_state.dart';
import 'modes/route_builder/services/route_builder_service.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialize FFI for desktop platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider(create: (_) => DatabaseService()),
        Provider(create: (_) => GpxService()),
        Provider(
          create: (context) => SegmentService(
            context.read<DatabaseService>(),
          ),
        ),
        
        // State management services
        ChangeNotifierProvider(create: (_) => ModeService()),
        ChangeNotifierProvider(create: (_) => MapService()),
        
        // Feature services
        ChangeNotifierProvider(
          create: (context) => SegmentLibraryService(
            context.read<SegmentService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ImportService(
            context.read<SegmentService>(),
            context.read<SegmentLibraryService>(),
          ),
        ),
        
        // Route builder services
        ChangeNotifierProvider(create: (_) => RouteBuilderStateProvider()),
        ChangeNotifierProvider(
          create: (context) => RouteBuilderService(
            context.read<RouteBuilderStateProvider>(),
            context.read<SegmentService>(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MapDesk',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: 'MapDesk',
              menus: [
                PlatformMenuItem(
                  label: 'Quit',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                  onSelected: () => SystemNavigator.pop(),
                ),
              ],
            ),
            PlatformMenu(
              label: 'File',
              menus: [
                PlatformMenuItem(
                  label: 'Open',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      HomeScreen.openGpxFile(context);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Reset Database',
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      HomeScreen.resetDatabase(context);
                    }
                  },
                ),
              ],
            ),
            PlatformMenu(
              label: 'Mode',
              menus: [
                PlatformMenuItem(
                  label: 'Map View',
                  shortcut: const SingleActivator(LogicalKeyboardKey.digit1, meta: true),
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      context.read<ModeService>().setMode(AppMode.map);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Import Track',
                  shortcut: const SingleActivator(LogicalKeyboardKey.digit2, meta: true),
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      context.read<ModeService>().setMode(AppMode.importTrack);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Segment Library',
                  shortcut: const SingleActivator(LogicalKeyboardKey.digit3, meta: true),
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      context.read<ModeService>().setMode(AppMode.segmentLibrary);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Route Builder',
                  shortcut: const SingleActivator(LogicalKeyboardKey.digit4, meta: true),
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      context.read<ModeService>().setMode(AppMode.routeBuilder);
                    }
                  },
                ),
              ],
            ),
            PlatformMenu(
              label: 'Window',
              menus: [
                PlatformMenuItem(
                  label: 'MapDesk',
                  onSelected: () {
                    final context = navigatorKey.currentContext;
                    if (context != null) {
                      FocusScope.of(context).requestFocus();
                    }
                  },
                ),
              ],
            ),
          ],
          child: const HomeScreen(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Global key for accessing the navigator context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
