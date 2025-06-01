import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/segment.dart';

/// Widget that displays the selected segment on the map.
class SegmentLibraryMap extends StatelessWidget {
  final Segment? selectedSegment;

  const SegmentLibraryMap({
    super.key,
    required this.selectedSegment,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedSegment == null) {
      return const Center(
        child: Text('Select a segment to view on map'),
      );
    }

    final points = selectedSegment!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);

    return FlutterMap(
      options: MapOptions(
        initialCenter: bounds.center,
        initialZoom: 13,
        cameraConstraint: CameraConstraint.contain(
          bounds: bounds,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mapdesk.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ],
        ),
        // Direction arrows
        PolylineLayer(
          polylines: _createDirectionArrows(points, context),
        ),
        // Start marker
        MarkerLayer(
          markers: [
            Marker(
              point: points.first,
              width: 20,
              height: 20,
              child: Icon(
                Icons.play_arrow,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            // End marker
            Marker(
              point: points.last,
              width: 20,
              height: 20,
              child: Icon(
                Icons.stop,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Polyline> _createDirectionArrows(List<LatLng> points, BuildContext context) {
    if (points.length < 2) return [];

    final arrows = <Polyline>[];
    final arrowSpacing = 5; // Show arrow every 5 points
    final arrowSize = 0.0001; // Size of arrow in degrees

    for (var i = 0; i < points.length - 1; i += arrowSpacing) {
      if (i + 1 >= points.length) break;

      final start = points[i];
      final end = points[i + 1];
      
      // Calculate direction vector
      final dx = end.longitude - start.longitude;
      final dy = end.latitude - start.latitude;
      final length = sqrt(dx * dx + dy * dy);
      
      // Normalize and scale
      final ndx = dx / length * arrowSize;
      final ndy = dy / length * arrowSize;
      
      // Calculate perpendicular vector for arrow wings
      final pdx = -ndy;
      final pdy = ndx;
      
      // Calculate arrow points
      final arrowBase = LatLng(
        start.latitude + dy * 0.5,
        start.longitude + dx * 0.5,
      );
      
      final arrowLeft = LatLng(
        arrowBase.latitude + pdy,
        arrowBase.longitude + pdx,
      );
      
      final arrowRight = LatLng(
        arrowBase.latitude - pdy,
        arrowBase.longitude - pdx,
      );
      
      arrows.add(Polyline(
        points: [arrowLeft, arrowBase, arrowRight],
        color: Theme.of(context).colorScheme.primary,
        strokeWidth: 2,
      ));
    }

    return arrows;
  }
} 