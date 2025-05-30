import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/simple_gpx_track.dart';
import '../services/gpx_service.dart';
import '../services/map_service.dart';
import '../widgets/map_view.dart';
import '../services/database_service.dart';
import '../widgets/segment_splitter.dart';
import '../models/segment.dart';
import '../widgets/map_controls.dart';
import '../widgets/segment_library_view.dart';
import '../widgets/route_builder_view.dart';
import '../widgets/import_track_view.dart';
import '../screens/import_screen.dart';
import '../services/import_service.dart';
import '../services/view_service.dart';

/// Main home screen for MapDesk Phase 2
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
                context.read<ViewService>().setView(ViewState.mapView);
              },
            ),
            PlatformMenuItem(
              label: 'Import Track',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit2, meta: true),
              onSelected: () {
                context.read<ViewService>().setView(ViewState.importTrack);
              },
            ),
            PlatformMenuItem(
              label: 'Segment Library',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit3, meta: true),
              onSelected: () {
                context.read<ViewService>().setView(ViewState.segmentLibrary);
              },
            ),
            PlatformMenuItem(
              label: 'Route Builder',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit4, meta: true),
              onSelected: () {
                context.read<ViewService>().setView(ViewState.routeBuilder);
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
      child: Consumer<ViewService>(
        builder: (context, viewService, _) {
          return Scaffold(
            body: _buildCurrentView(context, viewService.currentView),
          );
        },
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context, ViewState view) {
    switch (view) {
      case ViewState.mapView:
        return const MapView();
      case ViewState.importTrack:
        return const ImportTrackView();
      case ViewState.segmentLibrary:
        // TODO: Implement segment library view
        return const Center(child: Text('Segment Library'));
      case ViewState.routeBuilder:
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

  void _openImportWindow(BuildContext context) {
    Navigator.pushNamed(context, '/import');
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