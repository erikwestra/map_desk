import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/segment_service.dart';
import '../../core/services/route_sidebar_service.dart';
import '../../core/models/segment.dart';
import '../../main.dart';

/// Internal state enum for the create mode
enum _CreateState {
  awaitingStartPoint,
  awaitingFirstSegment,
  awaitingNextSegment
}

/// Controller for the Create mode, which handles route creation.
class CreateModeController extends ModeController {
  _CreateState _currentState = _CreateState.awaitingStartPoint;
  LatLng? _startPoint;
  List<Segment> _routeSegments = [];

  CreateModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'Create';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => true;

  @override
  void onActivate() {
    // Set segment sidebar to non-editable in Create mode
    uiContext.segmentSidebarService.setEditable(false);
    
    // Reset state
    _resetState();
    
    // Update map content to show all segments
    _updateMapContent();
    
    // Update status bar with initial state
    _updateStatusBar();
  }

  @override
  void onDeactivate() {
    // Reset segment sidebar to editable when leaving Create mode
    uiContext.segmentSidebarService.setEditable(true);
    
    // Clear map content
    uiContext.mapViewService.setContent([]);
    
    // Clear status bar
    uiContext.statusBarService.clearContent();
  }

  void _resetState() {
    _currentState = _CreateState.awaitingStartPoint;
    _startPoint = null;
    _routeSegments = [];
    uiContext.routeSidebarService.setSegments([]);
  }

  void _updateStatusBar() {
    switch (_currentState) {
      case _CreateState.awaitingStartPoint:
        uiContext.statusBarService.setContent(
          const Text('Click on the map to set the starting point'),
        );
        break;
      case _CreateState.awaitingFirstSegment:
        uiContext.statusBarService.setContent(
          const Text('Select the first segment to add to your route'),
        );
        break;
      case _CreateState.awaitingNextSegment:
        uiContext.statusBarService.setContent(
          Text('Route has ${_routeSegments.length} segments. Select the next segment to add'),
        );
        break;
    }
  }

  void _updateMapContent() async {
    // Get all segments
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final segments = await segmentService.getAllSegments();
    final theme = Theme.of(navigatorKey.currentContext!);
    
    // Create map content with all segments
    final content = <Widget>[
      // All segments layer
      PolylineLayer(
        polylines: segments.map((segment) {
          final isInRoute = _routeSegments.any((s) => s.id == segment.id);
          return Polyline(
            points: segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
            color: isInRoute 
              ? theme.colorScheme.secondary.withOpacity(0.8)
              : theme.colorScheme.primary.withOpacity(0.8),
            strokeWidth: isInRoute ? 4.0 : 3.0,
          );
        }).toList(),
      ),
    ];

    // Add start point marker if set
    if (_startPoint != null) {
      content.add(
        CircleLayer(
          circles: [
            CircleMarker(
              point: _startPoint!,
              color: Colors.green,
              radius: 8.0,
            ),
          ],
        ),
      );
    }

    // Set the map content
    uiContext.mapViewService.setContent(content);
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
      case 'map_click':
        if (eventData is LatLng) {
          await _handleMapClick(eventData);
        }
        break;
      case 'segment_selected':
        if (eventData is Segment) {
          await _handleSegmentSelected(eventData);
        }
        break;
      default:
        print('CreateModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleMapClick(LatLng point) async {
    if (_currentState == _CreateState.awaitingStartPoint) {
      _startPoint = point;
      _currentState = _CreateState.awaitingFirstSegment;
      _updateMapContent();
      _updateStatusBar();
    }
  }

  Future<void> _handleSegmentSelected(Segment segment) async {
    if (_currentState == _CreateState.awaitingStartPoint) return;

    // Add segment to route
    _routeSegments.add(segment);
    uiContext.routeSidebarService.setSegments(_routeSegments);

    // Update state
    _currentState = _CreateState.awaitingNextSegment;
    
    // Update UI
    _updateMapContent();
    _updateStatusBar();
  }

  Future<void> _handleOpen() async {
    // TODO: Implement file opening in Create mode
    print('CreateModeController: Open called');
  }

  Future<void> _handleSaveRoute() async {
    if (_routeSegments.isEmpty) {
      // Show error if no segments in route
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot save empty route'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // TODO: Implement save route in Create mode
    print('CreateModeController: Save route called');
  }

  Future<void> _handleUndo() async {
    if (_routeSegments.isEmpty) {
      if (_currentState == _CreateState.awaitingFirstSegment) {
        // If no segments but we have a start point, remove it
        _startPoint = null;
        _currentState = _CreateState.awaitingStartPoint;
      }
    } else {
      // Remove last segment
      _routeSegments.removeLast();
      uiContext.routeSidebarService.setSegments(_routeSegments);
      
      // Update state
      _currentState = _routeSegments.isEmpty 
        ? _CreateState.awaitingFirstSegment 
        : _CreateState.awaitingNextSegment;
    }

    // Update UI
    _updateMapContent();
    _updateStatusBar();
  }

  Future<void> _handleClearTrack() async {
    _resetState();
    _updateMapContent();
    _updateStatusBar();
  }
}
