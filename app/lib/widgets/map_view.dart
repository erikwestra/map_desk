import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/map_service.dart';
import 'map_controls.dart';
import 'segment_splitter.dart';

class MapView extends StatefulWidget {
  final void Function(int)? onPointSelected;
  final int? splitStartIndex;
  final int? splitEndIndex;

  const MapView({
    super.key,
    this.onPointSelected,
    this.splitStartIndex,
    this.splitEndIndex,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  int? _splitStartIndex;
  int? _splitEndIndex;

  void _handlePointSelect(int index) {
    setState(() {
      if (_splitStartIndex == null) {
        _splitStartIndex = index;
      } else if (_splitEndIndex == null) {
        if (index > _splitStartIndex!) {
          _splitEndIndex = index;
        } else {
          _splitStartIndex = index;
        }
      } else {
        _splitStartIndex = index;
        _splitEndIndex = null;
      }
    });
  }

  void _handleCancel() {
    setState(() {
      _splitStartIndex = null;
      _splitEndIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();
    final isSplitMode = mapService.isTrackLoaded && mapService.isSplitMode;
    final trackPoints = mapService.trackPoints;

    return Stack(
      children: [
        FlutterMap(
          mapController: mapService.mapController,
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
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapdesk.app',
              maxZoom: 19,
            ),
            if (mapService.isTrackLoaded) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackPoints,
                    color: const Color(0xFFFF3B30),
                    strokeWidth: 3.0,
                  ),
                ],
              ),
              PolylineLayer(
                polylines: mapService.segments.map((segment) {
                  return Polyline(
                    points: segment.points.map((p) => p.toLatLng()).toList(),
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  );
                }).toList(),
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
        MapControls(mapController: mapService.mapController),
        if (isSplitMode)
          SegmentSplitter(
            track: mapService.track!,
            onSegmentCreated: (segment) {
              mapService.addSegment(segment);
              mapService.toggleSplitMode();
              _handleCancel();
            },
            onCancel: () {
              mapService.toggleSplitMode();
              _handleCancel();
            },
            startIndex: _splitStartIndex,
            endIndex: _splitEndIndex,
            onPointSelected: _handlePointSelect,
          ),
      ],
    );
  }
} 