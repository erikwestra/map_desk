import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/gpx_service.dart';
import '../services/database_service.dart';
import '../services/map_service.dart';
import '../widgets/map_view.dart';
import '../models/gpx_track.dart';
import '../widgets/segment_splitter.dart';
import '../models/segment.dart';
import '../widgets/map_controls.dart';

class ImportScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const ImportScreen({
    super.key,
    required this.databaseService,
  });

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  GpxTrack? _importedTrack;
  int? _splitStartIndex;
  int? _splitEndIndex;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Start file picker immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _importGpxFile();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _importGpxFile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _importedTrack = null;
      _splitStartIndex = null;
      _splitEndIndex = null;
    });

    try {
      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final track = await GpxService.parseGpxFile(file.path);
        setState(() {
          _importedTrack = track;
          _successMessage = 'Track imported successfully';
        });
        // Zoom to show the entire track
        if (mounted && track.points.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final points = track.points.map((p) => p.toLatLng()).toList();
            final bounds = LatLngBounds.fromPoints(points);
            
            await Future.delayed(const Duration(milliseconds: 100));
            
            _mapController.fitBounds(
              bounds,
              options: const FitBoundsOptions(
                padding: EdgeInsets.all(50.0),
              ),
            );

            await Future.delayed(const Duration(milliseconds: 100));
            final center = _mapController.camera.center;
            final zoom = _mapController.camera.zoom;
            
            _mapController.move(center, zoom + 0.0001);
            await Future.delayed(const Duration(milliseconds: 50));
            _mapController.move(center, zoom - 0.0001);
            await Future.delayed(const Duration(milliseconds: 50));
            _mapController.move(center, zoom);
          });
        }
      } else {
        // User cancelled file selection, close the window
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _handleSegmentCreated(Segment segment) {
    widget.databaseService.saveSegment(segment);
    setState(() {
      _splitStartIndex = null;
      _splitEndIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();
    final isSplitMode = _importedTrack != null && mapService.isSplitMode;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Import Track'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    if (_importedTrack == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Track'),
        actions: [
          if (_importedTrack != null) ...[
            TextButton(
              onPressed: () {
                mapService.toggleSplitMode();
              },
              child: Text(
                mapService.isSplitMode ? 'Exit Split Mode' : 'Enter Split Mode',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _importedTrack != null && _importedTrack!.points.isNotEmpty
                  ? _importedTrack!.points.first.toLatLng()
                  : const LatLng(0, 0),
              initialZoom: 2,
              interactionOptions: const InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom | InteractiveFlag.scrollWheelZoom,
              ),
              maxZoom: 18.0,
              minZoom: 2.0,
              onMapReady: () {
                if (_importedTrack != null && _importedTrack!.points.isNotEmpty) {
                  final points = _importedTrack!.points.map((p) => p.toLatLng()).toList();
                  final bounds = LatLngBounds.fromPoints(points);
                  _mapController.fitBounds(
                    bounds,
                    options: const FitBoundsOptions(
                      padding: EdgeInsets.all(50.0),
                    ),
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mapdesk.app',
                maxZoom: 19,
                tileProvider: NetworkTileProvider(),
                tileBuilder: (context, tileWidget, tile) {
                  return tileWidget;
                },
              ),
              if (_importedTrack != null) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _importedTrack!.points.map((p) => p.toLatLng()).toList(),
                      color: const Color(0xFFFF3B30),
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
                // Start and end markers
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _importedTrack!.points.first.toLatLng(),
                      color: Colors.green,
                      radius: 8.0,
                    ),
                    CircleMarker(
                      point: _importedTrack!.points.last.toLatLng(),
                      color: Colors.red,
                      radius: 8.0,
                    ),
                  ],
                ),
                if (isSplitMode && _handlePointSelect != null)
                  MarkerLayer(
                    markers: _importedTrack!.points.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value.toLatLng();
                      final isSelected = index == _splitStartIndex || index == _splitEndIndex;
                      return Marker(
                        point: point,
                        width: 24,
                        height: 24,
                        child: GestureDetector(
                          onTap: () => _handlePointSelect(index),
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
          MapControls(mapController: _mapController),
          if (isSplitMode)
            SegmentSplitter(
              track: _importedTrack!,
              onSegmentCreated: _handleSegmentCreated,
              onCancel: _handleCancel,
              startIndex: _splitStartIndex,
              endIndex: _splitEndIndex,
              onPointSelected: _handlePointSelect,
            ),
        ],
      ),
    );
  }
} 