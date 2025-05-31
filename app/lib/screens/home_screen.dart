import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../core/services/mode_service.dart';
import '../core/services/gpx_service.dart';
import '../modes/map/services/map_service.dart';
import '../modes/map/widgets/map_view.dart';
import '../modes/import_track/widgets/import_track_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        // TODO: Implement segment library view
        return const Center(child: Text('Segment Library'));
      case AppMode.routeBuilder:
        // TODO: Implement route builder view
        return const Center(child: Text('Route Builder'));
    }
  }

  Future<void> _openGpxFile(BuildContext context) async {
    bool isLoading = false;
    String? errorMessage;
    String? successMessage;

    try {
      if (isLoading) return;

      isLoading = true;
      errorMessage = null;

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
      errorMessage = e.toString();
      context.read<MapService>().clearTrack();
    } finally {
      isLoading = false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage ?? errorMessage ?? '')),
      );
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