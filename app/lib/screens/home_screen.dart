import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/gpx_track.dart';
import '../services/gpx_service.dart';
import '../widgets/placeholder_map.dart';

/// Main home screen for MapDesk Phase 1
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GpxTrack? _loadedTrack;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'MapDesk',
          menus: [
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
        body: PlaceholderMap(
          loadedTrack: _loadedTrack,
          errorMessage: _errorMessage,
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final track = await GpxService.parseGpxFile(file.path!);
          setState(() {
            _loadedTrack = track;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Could not access the selected file';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loadedTrack = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _bringToFront() {
    // On macOS, this will bring the window to the front
    // Flutter handles this automatically when the menu item is selected
    // but we can also programmatically request focus
    if (mounted) {
      FocusScope.of(context).requestFocus();
    }
  }

  void _quitApp() {
    SystemNavigator.pop();
  }
} 