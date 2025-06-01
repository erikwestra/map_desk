import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/models/segment.dart';
import 'package:map_desk/shared/widgets/base_map_view.dart';
import 'package:map_desk/shared/widgets/map_controls.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';

/// Map view widget for displaying segments in the segment library.
class SegmentLibraryMap extends StatelessWidget {
  const SegmentLibraryMap({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentLibraryService>();
    final selectedSegment = service.selectedSegment;

    return Stack(
      children: [
        BaseMapView(
          mapController: service.mapController,
          initialZoom: service.lastZoomLevel,
          children: [
            if (selectedSegment != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: selectedSegment.points.map((p) => 
                      LatLng(p.latitude, p.longitude)
                    ).toList(),
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3.0,
                  ),
                ],
              ),
          ],
        ),
        MapControls(mapController: service.mapController),
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