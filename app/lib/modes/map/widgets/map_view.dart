// Main map view widget that displays the track and handles user interactions.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/map_service.dart';
import '../../../../shared/widgets/map_controls.dart';
import '../../../../shared/widgets/base_map_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();
    final trackPoints = mapService.trackPoints;

    return Stack(
      children: [
        BaseMapView(
          mapController: mapService.mapController,
          initialZoom: 2.0,
          onMapReady: () {
            mapService.setMapReady(true);
          },
          children: [
            if (mapService.isTrackLoaded) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackPoints,
                    color: const Color(0xFFFF3B30),
                    strokeWidth: 3.0,
                  ),
                ],
              ),
              // Start and end markers
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: trackPoints.first,
                    color: Colors.green,
                    radius: 8.0,
                  ),
                  CircleMarker(
                    point: trackPoints.last,
                    color: Colors.red,
                    radius: 8.0,
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