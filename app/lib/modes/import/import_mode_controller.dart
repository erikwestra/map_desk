import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../../core/interfaces/mode_controller.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/gpx_service.dart';
import '../../core/models/simple_gpx_track.dart';

/// Controller for the Import mode, which handles track import and segment creation.
class ImportModeController implements ModeController {
  SimpleGpxTrack? _currentTrack;
  bool _isLoading = false;

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;

  @override
  String get modeName => 'Import';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  Widget buildLeftSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('Import Sidebar'),
      ),
    );
  }

  @override
  Widget buildRightSidebar(BuildContext context) {
    return const Center(child: Text('Right Sidebar'));
  }

  @override
  Widget buildMapContent(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'Import Map Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget buildStatusBarContent(BuildContext context) {
    return const Text('Import Mode');
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}

  @override
  Future<void> handleEvent(String eventType, dynamic eventData) async {
    switch (eventType) {
      // Menu events
      case 'menu_open':
        await _handleOpen();
        break;
      case 'menu_save_route':
        await _handleSaveRoute();
        break;
      case 'menu_undo':
        await _handleUndo();
        break;
      case 'menu_clear_track':
        await _handleClearTrack();
        break;
      
      // UI interaction events
      case 'map_click':
        await _handleMapClick(eventData as LatLng);
        break;
      case 'segment_selected':
        await _handleSegmentSelection(eventData);
        break;
      case 'route_point_selected':
        await _handleRoutePointSelection(eventData);
        break;
      default:
        print('ImportModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleOpen() async {
    if (_isLoading) return;

    try {
      _isLoading = true;

      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final track = await GpxService.parseGpxFile(File(file.path));
        _currentTrack = track;
      }
    } catch (e) {
      print('Failed to load GPX file: ${e.toString()}');
      _currentTrack = null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _handleSaveRoute() async {
    // No-op in Import mode
    print('ImportModeController: Save route called (disabled)');
  }

  Future<void> _handleUndo() async {
    // TODO: Implement undo in Import mode
    print('ImportModeController: handleUndo called');
  }

  Future<void> _handleClearTrack() async {
    // TODO: Implement track clearing in Import mode
    print('ImportModeController: handleClearTrack called');
    _currentTrack = null;
  }

  Future<void> _handleMapClick(LatLng point) async {
    // In Import mode, map clicks might:
    // - Select start/end points for segment creation
    // - Show point details
    // - Update the status bar
    print('ImportModeController: Map clicked at $point');
  }

  Future<void> _handleSegmentSelection(dynamic segment) async {
    // In Import mode, segment selection might:
    // - Show the segment on the map
    // - Display segment details
    // - Update the status bar
    print('ImportModeController: Segment selected: $segment');
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // In Import mode, route point selection might:
    // - Show point details
    // - Update the status bar
    // - Center the map on the point
    print('ImportModeController: Route point selected: $point');
  }
}
