// Specialized map view for track import with split mode and point selection functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/import_service.dart';
import 'map_controls.dart';

class ImportTrackMapView extends StatelessWidget {
  final Function(int) onPointSelected;

  const ImportTrackMapView({
    super.key,
    required this.onPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportService>(
      builder: (context, importService, _) {
        return FlutterMap(
          mapController: importService.mapController,
          options: MapOptions(
            onTap: (_, point) {
              // TODO: Implement point selection logic
            },
            onMapReady: () {
              importService.setMapReady(true);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.map_desk',
            ),
            PolylineLayer(
              polylines: [
                if (importService.track != null)
                  Polyline(
                    points: importService.trackPoints,
                    color: Colors.blue,
                    strokeWidth: 3.0,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (importService.startPointIndex != null)
                  Marker(
                    point: importService.trackPoints[importService.startPointIndex!],
                    child: const Icon(
                      Icons.flag,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                if (importService.endPointIndex != null)
                  Marker(
                    point: importService.trackPoints[importService.endPointIndex!],
                    child: const Icon(
                      Icons.flag,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
} 