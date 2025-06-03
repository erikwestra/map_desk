import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../services/mode_service.dart';
import '../services/map_view_service.dart';
import '../interfaces/mode_controller.dart';
import '../../main.dart';  // Import for ServiceProvider
import 'map_controls.dart';  // Import for MapControls

/// A widget that displays the map content.
/// Shows content for the current mode and handles map interactions.
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final modeService = context.watch<ModeService>();
    final mapViewService = context.watch<MapViewService>();
    final currentMode = modeService.currentMode;

    final content = mapViewService.content;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Check if Return/Enter key was pressed
          if (event.logicalKey == LogicalKeyboardKey.enter || 
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // Forward the event to the current mode
            currentMode?.handleEvent('key_enter', null);
            return KeyEventResult.handled;
          }
          // Check if Escape key was pressed
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            // Forward the event to the current mode
            currentMode?.handleEvent('key_escape', null);
            return KeyEventResult.handled;
          }
          // Check if + key was pressed (both main keyboard and numpad)
          if (event.logicalKey == LogicalKeyboardKey.add || 
              event.logicalKey == LogicalKeyboardKey.numpadAdd) {
            // Zoom in by one level
            final currentZoom = mapViewService.mapController.zoom;
            mapViewService.mapController.move(
              mapViewService.mapController.center,
              currentZoom + 1,
            );
            return KeyEventResult.handled;
          }
          // Check if - key was pressed (both main keyboard and numpad)
          if (event.logicalKey == LogicalKeyboardKey.minus || 
              event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
            // Zoom out by one level
            final currentZoom = mapViewService.mapController.zoom;
            mapViewService.mapController.move(
              mapViewService.mapController.center,
              currentZoom - 1,
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapViewService.mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2.0,
              onTap: (tapPosition, point) {
                currentMode?.handleEvent('map_click', point);
              },
              onMapReady: () {
                currentMode?.handleEvent('map_ready', null);
              },
              onMapEvent: (event) {
                // Map event handling if needed
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mapdesk.app',
              ),
              ...content,
            ],
          ),
          MapControls(mapController: mapViewService.mapController),
        ],
      ),
    );
  }
}
