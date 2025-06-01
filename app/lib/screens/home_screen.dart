import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../core/services/mode_service.dart';
import '../core/services/gpx_service.dart';
import '../core/services/database_service.dart';
import '../modes/map/services/map_service.dart';
import '../modes/map/widgets/map_view.dart';
import '../modes/import_track/widgets/import_track_view.dart';
import '../modes/segment_library/screens/segment_library_screen.dart';
import '../modes/segment_library/services/segment_library_service.dart';
import '../core/services/segment_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showError(BuildContext context, String message) {
    print('HomeScreen: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'MapDesk',
          menus: [
            PlatformMenuItem(
              label: 'Quit',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
              onSelected: () => _quitApp(context),
            ),
          ],
        ),
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'Open',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
              onSelected: () => _openGpxFile(context),
            ),
            PlatformMenuItem(
              label: 'Reset Database',
              onSelected: () => _resetDatabase(context),
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
                context.read<ModeService>().setMode(AppMode.map);
              },
            ),
            PlatformMenuItem(
              label: 'Import Track',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit2, meta: true),
              onSelected: () {
                context.read<ModeService>().setMode(AppMode.importTrack);
              },
            ),
            PlatformMenuItem(
              label: 'Segment Library',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit3, meta: true),
              onSelected: () {
                context.read<ModeService>().setMode(AppMode.segmentLibrary);
              },
            ),
            PlatformMenuItem(
              label: 'Route Builder',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit4, meta: true),
              onSelected: () {
                context.read<ModeService>().setMode(AppMode.routeBuilder);
              },
            ),
          ],
        ),
        PlatformMenu(
          label: 'Window',
          menus: [
            PlatformMenuItem(
              label: 'MapDesk',
              onSelected: () => _bringToFront(context),
            ),
          ],
        ),
      ],
      child: Consumer<ModeService>(
        builder: (context, modeService, child) {
          return Scaffold(
            body: _buildCurrentView(context, modeService.currentMode),
          );
        },
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context, AppMode mode) {
    switch (mode) {
      case AppMode.map:
        return const MapView();
      case AppMode.importTrack:
        return const ImportTrackView();
      case AppMode.segmentLibrary:
        return const SegmentLibraryScreen();
      case AppMode.routeBuilder:
        // TODO: Implement route builder view
        return const Center(child: Text('Route Builder'));
    }
  }

  Future<void> _openGpxFile(BuildContext context) async {
    bool isLoading = false;
    String? successMessage;

    try {
      if (isLoading) return;

      isLoading = true;

      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final track = await GpxService.parseGpxFile(file.path);
        context.read<MapService>().setTrack(track);
        successMessage = 'GPX file loaded successfully';
      }
    } catch (e) {
      _showError(context, 'Failed to load GPX file: ${e.toString()}');
      context.read<MapService>().clearTrack();
    } finally {
      isLoading = false;
    }

    if (mounted && successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
  }

  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text('Are you sure you want to delete all segments? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<DatabaseService>().deleteAllSegments();
        await context.read<SegmentLibraryService>().refreshSegments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database reset successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          _showError(context, 'Failed to reset database: ${e.toString()}');
        }
      }
    }
  }

  void _bringToFront(BuildContext context) {
    if (mounted) {
      FocusScope.of(context).requestFocus();
    }
  }

  void _quitApp(BuildContext context) {
    SystemNavigator.pop();
  }
} 