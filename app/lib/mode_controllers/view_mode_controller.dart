import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:io';
import '../interfaces/mode_controller.dart';
import '../interfaces/mode_ui_context.dart';
import '../services/mode_service.dart';
import '../services/menu_service.dart';
import '../services/gpx_service.dart';
import '../models/simple_gpx_track.dart';
import '../main.dart';

/// Controller for the View mode, which handles map viewing and navigation.
class ViewModeController extends ModeController {
  SimpleGpxTrack? _currentTrack;
  bool _isLoading = false;

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;

  ViewModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'View';

  @override
  bool get showLeftSidebar => false;

  @override
  bool get showRightSidebar => false;

  @override
  void onActivate() {
    _updateMapContent();
  }

  @override
  void onDeactivate() {
    uiContext.mapViewService.clearContent();
  }

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {
    'currentTrack': _currentTrack,
  };

  @override
  void restoreState(Map<String, dynamic> state) {
    _currentTrack = state['currentTrack'] as SimpleGpxTrack?;
    _updateMapContent();
  }

  @override
  Future<void> handleEvent(String eventType, dynamic eventData) async {
    switch (eventType) {
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
      default:
        print('ViewModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleOpen() async {
    print('ViewModeController: Starting _handleOpen');
    if (_isLoading) {
      print('ViewModeController: Already loading, returning');
      return;
    }

    try {
      _isLoading = true;
      print('ViewModeController: Opening file picker');

      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      print('ViewModeController: File picker result: ${file?.path}');

      if (file != null) {
        print('ViewModeController: Parsing GPX file');
        final track = await GpxService.parseGpxFile(File(file.path));
        _currentTrack = track;
        
        print('ViewModeController: Updating map content');
        // Update the map content
        final points = track.points.map((p) => p.toLatLng()).toList();
        final bounds = LatLngBounds.fromPoints(points);
        
        // Set the map bounds to show the entire track
        uiContext.mapViewService.mapController.move(
          bounds.center,
          uiContext.mapViewService.mapController.camera.zoom,
        );
        uiContext.mapViewService.mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
        );
        
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
        print('ViewModeController: Track loaded successfully');
      } else {
        print('ViewModeController: No file selected');
      }
    } catch (e) {
      print('ViewModeController: Failed to load GPX file: $e');
      // TODO: Show error to user
    } finally {
      _isLoading = false;
      print('ViewModeController: Finished _handleOpen');
    }
  }

  Future<void> _handleSaveRoute() async {
    // TODO: Implement save route in View mode
    print('ViewModeController: Save route called');
  }

  Future<void> _handleUndo() async {
    // TODO: Implement undo in View mode
    print('ViewModeController: Undo called');
  }

  Future<void> _handleClearTrack() async {
    // TODO: Implement track clearing in View mode
    print('ViewModeController: Clear track called');
  }

  void _updateMapContent() {
    if (_currentTrack == null) {
      uiContext.mapViewService.setContent([]);
      return;
    }

    final points = _currentTrack!.points.map((p) => p.toLatLng()).toList();
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
