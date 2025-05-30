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
  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final isSplitMode = importService.isTrackLoaded && importService.isSplitMode;
    final trackPoints = importService.trackPoints;

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
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapdesk.app',
              maxZoom: 19,
            ),
            if (importService.isTrackLoaded) ...[
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
              if (isSplitMode && widget.onPointSelected != null)
                MarkerLayer(
                  markers: trackPoints.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    final isSelected = index == widget.splitStartIndex || index == widget.splitEndIndex;
                    return Marker(
                      point: point,
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        onTap: () => widget.onPointSelected!(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          width: 16,
                          height: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
        MapControls(mapController: importService.mapController),
      ],
    );
  }
} 