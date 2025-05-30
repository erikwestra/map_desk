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

  void _handleMapTap(LatLng point, List<LatLng> trackPoints, bool startOrEndOnly) {
    if (widget.onPointSelected == null) return;

    // Find the closest point within tolerance
    double minDistance = double.infinity;
    int? closestIndex;
    
    for (int i = 0; i < trackPoints.length; i++) {
      final trackPoint = trackPoints[i];
      final distance = Distance().distance(
        point,
        trackPoint,
      );
      
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
      widget.onPointSelected!(closestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final isSplitMode = importService.isTrackLoaded && importService.isSplitMode;
    final trackPoints = importService.trackPoints;
    final selectedPoints = importService.selectedPoints;
    final unselectedPoints = importService.unselectedPoints;
    final startPointIndex = importService.startPointIndex;
    final endPointIndex = importService.endPointIndex;
    final importState = importService.importState;

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
              // Handle tap based on import state
              switch (importState) {
                case ImportState.noFile:
                  // Do nothing when no file is loaded
                  return;
                
                case ImportState.fileLoaded:
                  // Select an endpoint of the track
                  _handleMapTap(point, trackPoints, true);
                  break;
                
                case ImportState.endpointSelected:
                case ImportState.segmentSelected:
                  // Select a point within the track for segment creation
                  _handleMapTap(point, trackPoints, false);
                  break;
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
              // Start point marker
              if (startPointIndex != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: trackPoints[startPointIndex],
                      color: const Color(0xFF007AFF),
                      radius: 8.0,
                    ),
                  ],
                ),
              // End point marker
              if (endPointIndex != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: trackPoints[endPointIndex],
                      color: const Color(0xFF34C759),
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