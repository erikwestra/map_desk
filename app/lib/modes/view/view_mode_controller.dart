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
import '../../core/models/simple_gpx_track.dart';

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
    // TODO: Implement file opening in View mode
    print('ViewModeController: Open called');
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
    // TODO: Update map content based on current track
  }
}
