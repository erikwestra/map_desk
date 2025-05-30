// Specialized map view for track import with split mode and point selection functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import 'map_controls.dart';
import 'segment_splitter.dart';

class ImportMapView extends StatefulWidget {
  final void Function(int)? onPointSelected;
  final int? splitStartIndex;
  final int? splitEndIndex;

  const ImportMapView({
    super.key,
    this.onPointSelected,
    this.splitStartIndex,
    this.splitEndIndex,
  });

  @override
  State<ImportMapView> createState() => _ImportMapViewState();
}

class _ImportMapViewState extends State<ImportMapView> {
  static const double _clickTolerance = 10.0;

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final isSplitMode = importService.isTrackLoaded && importService.isSplitMode;
    final trackPoints = importService.trackPoints;
    final selectedPoints = importService.selectedPoints;
    final unselectedPoints = importService.unselectedPoints;
    final selectedPointIndex = importService.selectedPointIndex;

    return Stack(
      children: [
        FlutterMap(
          mapController: importService.mapController,
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
            onMapReady: () {
              importService.setMapReady(true);
            },
            onTap: (tapPosition, point) {
              if (!isSplitMode || widget.onPointSelected == null) return;
              
              print('Tap at: ${point.latitude}, ${point.longitude}');
              
              // Find the closest point within tolerance
              double minDistance = double.infinity;
              int? closestIndex;
              
              for (int i = 0; i < trackPoints.length; i++) {
                final trackPoint = trackPoints[i];
                final distance = Distance().distance(
                  point,
                  trackPoint,
                );
                
                print('Point $i: ${trackPoint.latitude}, ${trackPoint.longitude} - Distance: $distance meters');
                
                if (distance < minDistance) {
                  minDistance = distance;
                  closestIndex = i;
                }
              }
              
              print('Closest point: $closestIndex at $minDistance meters');
              
              // Check if the closest point is within tolerance
              if (closestIndex != null && minDistance <= _clickTolerance) {
                print('Selecting point $closestIndex');
                widget.onPointSelected!(closestIndex);
              } else {
                print('No point within tolerance');
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapdesk.app',
              maxZoom: 19,
            ),
            if (importService.isTrackLoaded) ...[
              // Unselected portion of the track (red)
              if (unselectedPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: unselectedPoints,
                      color: const Color(0xFFFF3B30),
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
              // Selected portion of the track (blue)
              if (selectedPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: selectedPoints,
                      color: const Color(0xFF007AFF),
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
              // Selected point marker
              if (selectedPointIndex != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: trackPoints[selectedPointIndex],
                      color: const Color(0xFF007AFF),
                      radius: 8.0,
                    ),
                  ],
                ),
            ],
          ],
        ),
        MapControls(mapController: importService.mapController),
      ],
    );
  }
} 