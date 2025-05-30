import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/gpx_track.dart';
import '../services/gpx_service.dart';
import '../services/map_service.dart';
import '../widgets/map_view.dart';
import '../services/database_service.dart';
import '../widgets/segment_splitter.dart';
import '../models/segment.dart';
import '../widgets/map_controls.dart';

/// Main home screen for MapDesk Phase 2
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  GpxTrack? _importedTrack;
  int? _splitStartIndex;
  int? _splitEndIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'MapDesk',
          menus: [
            if (Theme.of(context).platform == TargetPlatform.macOS)
              PlatformMenuItemGroup(
                members: <PlatformMenuItem>[
                  PlatformMenuItem(
                    label: 'Quit',
                    onSelected: () => _quitApp(),
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyQ,
                      meta: true,
                    ),
                  ),
                ],
              ),
          ],
        ),
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'Open',
              onSelected: () => _openGpxFile(),
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyO,
                meta: true,
              ),
            ),
          ],
        ),
        PlatformMenu(
          label: 'Segments',
          menus: [
            PlatformMenuItem(
              label: 'Import Track',
              onSelected: () => _openImportWindow(),
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyI,
                meta: true,
              ),
            ),
          ],
        ),
        PlatformMenu(
          label: 'Window',
          menus: [
            PlatformMenuItem(
              label: 'MapDesk',
              onSelected: () => _bringToFront(),
            ),
          ],
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            const MapView(),
            if (_errorMessage != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGpxFile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final track = await GpxService.parseGpxFile(file.path);
        context.read<MapService>().setTrack(track);
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        context.read<MapService>().clearTrack();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openImportWindow() {
    Navigator.pushNamed(context, '/import');
  }

  void _bringToFront() {
    if (mounted) {
      FocusScope.of(context).requestFocus();
    }
  }

  void _quitApp() {
    SystemNavigator.pop();
  }
} 