// Widget for displaying a segment on the map
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/segment.dart';
import '../../../shared/widgets/map_controls.dart';
import '../../../shared/widgets/base_map_view.dart';

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

    return Stack(
      children: [
        BaseMapView(
          mapController: mapController,
          initialZoom: 2.0,
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
          children: [
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
        ),
        MapControls(mapController: mapController),
      ],
    );
  }
} 