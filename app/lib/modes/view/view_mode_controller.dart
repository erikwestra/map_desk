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

/// Controller for the View mode, which handles map viewing and navigation.
class ViewModeController implements ModeController {
  SimpleGpxTrack? _currentTrack;
  bool _isLoading = false;

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;

  @override
  String get modeName => 'View';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {
    'currentTrack': _currentTrack,
  };

  @override
  void restoreState(Map<String, dynamic> state) {
    _currentTrack = state['currentTrack'] as SimpleGpxTrack?;
  }

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
        print('ViewModeController: Unhandled event type: $eventType');
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
    // No-op in View mode
    print('ViewModeController: Save route called (disabled)');
  }

  Future<void> _handleUndo() async {
    // No-op in View mode
    print('ViewModeController: Undo called (disabled)');
  }

  Future<void> _handleClearTrack() async {
    _currentTrack = null;
  }

  Future<void> _handleMapClick(LatLng point) async {
    // In View mode, map clicks might:
    // - Show info about the clicked location
    // - Center the map on the clicked point
    // - Show elevation profile for the clicked point
    print('ViewModeController: Map clicked at $point');
  }

  Future<void> _handleSegmentSelection(dynamic segment) async {
    // In View mode, segment selection might:
    // - Show the segment on the map
    // - Display segment details
    // - Update the status bar
    print('ViewModeController: Segment selected: $segment');
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // In View mode, route point selection might:
    // - Show point details
    // - Update the status bar
    // - Center the map on the point
    print('ViewModeController: Route point selected: $point');
  }
}
