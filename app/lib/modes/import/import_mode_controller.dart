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
import '../../core/models/segment.dart';
import '../../main.dart';

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
  void onActivate() {
    // Show the current track in the segment sidebar
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    segmentSidebarService.setShowCurrentTrack(true);
    // Clear any existing selection
    segmentSidebarService.clearSelection();
  }

  @override
  void onDeactivate() {
    // Hide the current track in the segment sidebar
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    segmentSidebarService.setShowCurrentTrack(false);
  }

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}

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
      case 'track_selected':
        await _handleTrackSelected(eventData as Segment);
        break;
      default:
        print('ImportModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleOpen() async {
    // TODO: Implement file opening in Import mode
    print('ImportModeController: Open called');
  }

  Future<void> _handleSaveRoute() async {
    // TODO: Implement save route in Import mode
    print('ImportModeController: Save route called');
  }

  Future<void> _handleUndo() async {
    // TODO: Implement undo in Import mode
    print('ImportModeController: Undo called');
  }

  Future<void> _handleClearTrack() async {
    // TODO: Implement track clearing in Import mode
    print('ImportModeController: Clear track called');
  }

  Future<void> _handleTrackSelected(Segment track) async {
    // Update the current track in the segment sidebar service
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    segmentSidebarService.setCurrentTrack(track);
    
    // Update the map view to show the track
    uiContext.mapViewService.setContent([
      // TODO: Add track visualization to map
    ]);
  }
}
