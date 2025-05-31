// Specialized map view for track import with split mode and point selection functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/import_service.dart';
import '../../../shared/widgets/map_controls.dart';
import '../../../shared/widgets/base_map_view.dart';

class ImportTrackMapView extends StatefulWidget {
  final Function(int) onPointSelected;

  const ImportTrackMapView({
    super.key,
    required this.onPointSelected,
  });

  @override
  State<ImportTrackMapView> createState() => _ImportTrackMapViewState();
}

class _ImportTrackMapViewState extends State<ImportTrackMapView> {
  static const double _clickTolerance = 20.0; // 20 pixels
  ImportState? _previousState;

  void _handleMapTap(LatLng point, List<LatLng> trackPoints, bool startOrEndOnly) {
    final importService = context.read<ImportService>();
    final mapController = importService.mapController;

    // Find the closest point within tolerance
    double minDistance = double.infinity;
    int? closestIndex;
    
    for (int i = 0; i < trackPoints.length; i++) {
      final trackPoint = trackPoints[i];
      // Convert points to screen coordinates
      final pointScreen = mapController.latLngToScreenPoint(point);
      final trackPointScreen = mapController.latLngToScreenPoint(trackPoint);
      
      // Calculate pixel distance
      final dx = pointScreen.x - trackPointScreen.x;
      final dy = pointScreen.y - trackPointScreen.y;
      final distance = math.sqrt(dx * dx + dy * dy);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    
    // Check if the closest point is within tolerance
    if (closestIndex != null && minDistance <= _clickTolerance) {
      // If startOrEndOnly is true, only allow selecting first or last point
      if (startOrEndOnly) {
        if (closestIndex != 0 && closestIndex != trackPoints.length - 1) {
          return; // Ignore clicks on points that aren't first or last
        }
      }
      widget.onPointSelected(closestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final track = importService.track;
    final trackPoints = importService.trackPoints;
    final selectedPoints = importService.selectedPoints;
    final unselectedPoints = importService.unselectedPoints;
    final startPointIndex = importService.startPointIndex;
    final endPointIndex = importService.endPointIndex;
    final importState = importService.state;

    return Stack(
      children: [
        BaseMapView(
          mapController: importService.mapController,
          initialZoom: importService.lastZoomLevel,
          onMapReady: () {
            importService.setMapReady(true);
            // If we have a track and a start point, pan to it
            if (importService.track != null && importService.startPointIndex != null) {
              final point = importService.track!.points[importService.startPointIndex!].toLatLng();
              importService.mapController.move(point, importService.lastZoomLevel);
            }
          },
          onTap: (point) {
            // Handle tap based on import state
            switch (importState) {
              case ImportState.noFile:
                // Do nothing when no file is loaded
                return;
              
              case ImportState.fileLoaded:
                // Select an endpoint of the track
                _handleMapTap(point, trackPoints, true);
                break;
              
              case ImportState.startPointSelected:
              case ImportState.segmentSelected:
                // Select a point within the track for segment creation
                _handleMapTap(point, trackPoints, false);
                break;
            }
          },
          children: [
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
            ],
            // Point markers for all track points
            CircleLayer(
              circles: trackPoints.map((point) => CircleMarker(
                point: point,
                color: Colors.blue.withOpacity(0.5),
                borderColor: Colors.blue,
                borderStrokeWidth: 1.0,
                radius: 3.0,
              )).toList(),
            ),
            // Start and end point markers
            CircleLayer(
              circles: [
                if (startPointIndex != null)
                  CircleMarker(
                    point: trackPoints[startPointIndex!],
                    color: Colors.green.withOpacity(1.0),
                    borderColor: Colors.green,
                    borderStrokeWidth: 2.0,
                    radius: 10.0,
                  ),
                if (endPointIndex != null)
                  CircleMarker(
                    point: trackPoints[endPointIndex!],
                    color: Colors.red.withOpacity(1.0),
                    borderColor: Colors.red,
                    borderStrokeWidth: 2.0,
                    radius: 10.0,
                  ),
              ],
            ),
          ],
        ),
        MapControls(mapController: importService.mapController),
      ],
    );
  }
} 