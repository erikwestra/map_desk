import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:io';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/gpx_service.dart';
import '../../core/services/segment_sidebar_service.dart';
import '../../core/models/simple_gpx_track.dart';
import '../../core/models/segment.dart';
import '../../main.dart';

/// Controller for the Import mode, which handles track import and segment creation.
class ImportModeController extends ModeController {
  SimpleGpxTrack? _currentTrack;
  bool _isLoading = false;
  SegmentSidebarService? _segmentSidebarService;

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;

  ImportModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'Import';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  void onActivate() {
    // Initialize the segment sidebar service if not already initialized
    _segmentSidebarService ??= Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    
    // Show the current track in the segment sidebar
    _segmentSidebarService?.setShowCurrentTrack(true);
    // Clear any existing selection
    _segmentSidebarService?.clearSelection();
  }

  @override
  void onDeactivate() {
    // Hide the current track in the segment sidebar
    _segmentSidebarService?.setShowCurrentTrack(false);
  }

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}

  @override
  Future<void> handleEvent(String eventType, dynamic eventData) async {
    print('ImportModeController: Received event: $eventType');
    switch (eventType) {
      case 'menu_open':
        print('ImportModeController: Handling menu_open event');
        await _handleOpen();
        break;
      case 'track_selected':
        _handleTrackSelected(eventData as Segment);
        break;
      case 'segment_selected':
        _handleSegmentSelected(eventData as Segment);
        break;
      default:
        print('ImportModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleOpen() async {
    print('ImportModeController: Starting _handleOpen');
    if (_isLoading) {
      print('ImportModeController: Already loading, returning');
      return;
    }

    try {
      _isLoading = true;
      print('ImportModeController: Opening file picker');

      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      print('ImportModeController: File picker result: ${file?.path}');

      if (file != null) {
        print('ImportModeController: Parsing GPX file');
        final track = await GpxService.parseGpxFile(File(file.path));
        _currentTrack = track;
        
        // Convert GpxPoint to SegmentPoint
        final segmentPoints = track.points.map((p) => SegmentPoint(
          latitude: p.latitude,
          longitude: p.longitude,
          elevation: p.elevation,
        )).toList();
        
        // Convert SimpleGpxTrack to Segment for the sidebar
        final segment = Segment.fromPoints(
          name: track.name,
          allPoints: segmentPoints,
          startIndex: 0,
          endIndex: segmentPoints.length - 1,
        );
        
        print('ImportModeController: Updating sidebar with track');
        // Update the segment sidebar with the new track
        _segmentSidebarService?.setCurrentTrack(segment);
        
        print('ImportModeController: Updating map content');
        // Update the map content
        final points = track.points.map((p) => p.toLatLng()).toList();
        final bounds = LatLngBounds.fromPoints(points);
        
        uiContext.mapViewService.setContent([
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                color: Theme.of(navigatorKey.currentContext!).colorScheme.primary,
                strokeWidth: 3.0,
              ),
            ],
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: points.first,
                color: Colors.green,
                radius: 8.0,
              ),
              CircleMarker(
                point: points.last,
                color: Colors.red,
                radius: 8.0,
              ),
            ],
          ),
        ]);
        print('ImportModeController: Track loaded successfully');
      } else {
        print('ImportModeController: No file selected');
      }
    } catch (e) {
      print('ImportModeController: Failed to load GPX file: $e');
      // TODO: Show error to user
    } finally {
      _isLoading = false;
      print('ImportModeController: Finished _handleOpen');
    }
  }

  void _handleTrackSelected(Segment track) {
    // Update the map content to show the track
    final points = track.points.map((p) => p.toLatLng()).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    uiContext.mapViewService.setContent([
      PolylineLayer(
        polylines: [
          Polyline(
            points: points,
            color: Theme.of(navigatorKey.currentContext!).colorScheme.primary,
            strokeWidth: 3.0,
          ),
        ],
      ),
      CircleLayer(
        circles: [
          CircleMarker(
            point: points.first,
            color: Colors.green,
            radius: 8.0,
          ),
          CircleMarker(
            point: points.last,
            color: Colors.red,
            radius: 8.0,
          ),
        ],
      ),
    ]);
  }

  void _handleSegmentSelected(Segment segment) {
    // Update the map content to show the segment
    final points = segment.points.map((p) => p.toLatLng()).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    uiContext.mapViewService.setContent([
      PolylineLayer(
        polylines: [
          Polyline(
            points: points,
            color: Theme.of(navigatorKey.currentContext!).colorScheme.primary,
            strokeWidth: 3.0,
          ),
        ],
      ),
      CircleLayer(
        circles: [
          CircleMarker(
            point: points.first,
            color: Colors.green,
            radius: 8.0,
          ),
          CircleMarker(
            point: points.last,
            color: Colors.red,
            radius: 8.0,
          ),
        ],
      ),
    ]);
  }
}
