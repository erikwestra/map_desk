import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/mode_service.dart';
import '../modes/map/widgets/map_view.dart';
import '../modes/import_track/widgets/import_track_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ModeService>(
        builder: (context, modeService, child) {
          switch (modeService.currentMode) {
            case AppMode.map:
              return const MapView();
            case AppMode.importTrack:
              return const ImportTrackView();
            default:
              return const Center(child: Text('Unknown mode'));
          }
        },
      ),
    );
  }
} 