import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/gpx_service.dart';
import '../../core/models/simple_gpx_track.dart';

/// Controller for the Import mode, which handles track import and segment creation.
class ImportModeController extends ModeController {
  SimpleGpxTrack? _currentTrack;
  bool _isLoading = false;

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
        if (eventData is LatLng) {
          await _handleMapClick(eventData);
        }
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
    // TODO: Implement save route
    print('ImportModeController: Save route called');
  }

  Future<void> _handleUndo() async {
    // TODO: Implement undo
    print('ImportModeController: Undo called');
  }

  Future<void> _handleClearTrack() async {
    _currentTrack = null;
  }

  Future<void> _handleMapClick(LatLng point) async {
    // TODO: Implement map click handling
    print('ImportModeController: Map clicked at $point');
  }

  Future<void> _handleSegmentSelection(dynamic segment) async {
    // TODO: Implement segment selection
    print('ImportModeController: Segment selected: $segment');
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // TODO: Implement route point selection
    print('ImportModeController: Route point selected: $point');
  }
}
