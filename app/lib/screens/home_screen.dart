import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/gpx_track.dart';
import '../services/gpx_service.dart';
import '../services/map_service.dart';
import '../widgets/map_view.dart';

/// Main home screen for MapDesk Phase 2
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
        body: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              final bool isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
              if (event.logicalKey == LogicalKeyboardKey.keyQ && 
                  isMetaPressed) {
                _quitApp();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.keyO && 
                        isMetaPressed) {
                _openGpxFile();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            children: [
              const MapView(),
              if (_errorMessage != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
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
          context.read<MapService>().setTrack(track);
          setState(() {
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
        context.read<MapService>().clearTrack();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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