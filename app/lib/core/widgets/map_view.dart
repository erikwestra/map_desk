import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/mode_service.dart';
import '../interfaces/mode_controller.dart';

/// A widget that displays the map content.
/// This is a placeholder that will be replaced with actual map functionality.
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final modeService = context.watch<ModeService>();
    final currentMode = modeService.currentMode;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: 2.0,
            onTap: (tapPosition, point) {
              currentMode?.handleEvent('map_click', point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapdesk.app',
            ),
          ],
        ),
      ],
    );
  }
}
