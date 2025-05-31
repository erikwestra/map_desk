// Widget for displaying a segment on the map
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/segment.dart';

class ImportSegmentMapView extends StatelessWidget {
  final Segment segment;
  final MapController mapController;

  const ImportSegmentMapView({
    super.key,
    required this.segment,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onMapReady: () {
          // Zoom to segment bounds when map is ready
          if (points.isNotEmpty) {
            final bounds = LatLngBounds.fromPoints(points);
            mapController.fitBounds(
              bounds,
              options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.map_desk',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              color: Colors.blue,
              strokeWidth: 3.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Start point marker
            Marker(
              point: points.first,
              child: const Icon(
                Icons.flag,
                color: Colors.green,
                size: 20,
              ),
            ),
            // End point marker
            Marker(
              point: points.last,
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
  }
} 