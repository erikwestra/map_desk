import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/map_service.dart';
import 'map_controls.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();

    return Stack(
      children: [
        FlutterMap(
          mapController: mapService.mapController,
          options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: 2,
            interactionOptions: const InteractionOptions(
              enableScrollWheel: true,
              enableMultiFingerGestureRace: true,
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom | InteractiveFlag.scrollWheelZoom,
            ),
            maxZoom: 18.0,
            minZoom: 2.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapdesk.app',
              maxZoom: 19,
            ),
            if (mapService.isTrackLoaded) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: mapService.trackPoints,
                    color: const Color(0xFFFF3B30),
                    strokeWidth: 3.0,
                  ),
                ],
              ),
            ],
          ],
        ),
        MapControls(mapController: mapService.mapController),
      ],
    );
  }
} 