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
    final allSegments = service.segments;

    return Stack(
      children: [
        BaseMapView(
          mapController: service.mapController,
          initialZoom: service.lastZoomLevel,
          children: [
            // All segments layer
            PolylineLayer(
              polylines: allSegments.map((segment) {
                final isSelected = segment == selectedSegment;
                return Polyline(
                  points: segment.points.map((p) => 
                    LatLng(p.latitude, p.longitude)
                  ).toList(),
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: isSelected ? 4.0 : 2.0,
                );
              }).toList(),
            ),
            // Selected segment markers
            if (selectedSegment != null)
              MarkerLayer(
                markers: [
                  // Start point marker
                  Marker(
                    point: LatLng(
                      selectedSegment.points.first.latitude,
                      selectedSegment.points.first.longitude,
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // End point marker
                  Marker(
                    point: LatLng(
                      selectedSegment.points.last.latitude,
                      selectedSegment.points.last.longitude,
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        MapControls(mapController: service.mapController),
      ],
    );
  }
} 