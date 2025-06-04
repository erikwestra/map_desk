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
import '../../core/models/segment_in_route.dart';
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
  List<SegmentInRoute> _routeSegments = [];
  List<SegmentInRoute> _possibleSegments = [];
  final Distance _distance = Distance();

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
    _possibleSegments = [];
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
          Text('${_possibleSegments.length} possible segments found. Select one to add to your route'),
        );
        break;
      case _CreateState.awaitingNextSegment:
        uiContext.statusBarService.setContent(
          Text('Route has ${_routeSegments.length} segments. Select the next segment to add'),
        );
        break;
    }
  }

  /// Find segments that could be added to the route based on their start/end points
  Future<void> _calculatePossibleSegments(LatLng point) async {
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final allSegments = await segmentService.getAllSegments();
    
    _possibleSegments = allSegments.where((segment) {
      // Use the new calcDistanceToStart method
      final result = segment.calcDistanceToStart(point);
      final distance = result['distance'] as double;
      return distance <= 20.0;
    }).map((segment) {
      final result = segment.calcDistanceToStart(point);
      return SegmentInRoute(segment, result['direction'] as String);
    }).toList();
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
          final isInRoute = _routeSegments.any((s) => s.segment.id == segment.id);
          final isPossible = _possibleSegments.any((ps) => ps.segment.id == segment.id);
          
          Color color;
          double strokeWidth;
          
          if (isInRoute) {
            color = const Color(0xFF1A237E).withOpacity(0.9); // Dark blue
            strokeWidth = 8.0;
          } else if (isPossible) {
            color = theme.colorScheme.tertiary.withOpacity(0.7);
            strokeWidth = 8.0;
          } else {
            color = theme.colorScheme.primary.withOpacity(0.8);
            strokeWidth = 3.0;
          }
          
          return Polyline(
            points: segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
            color: color,
            strokeWidth: strokeWidth,
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

  /// Finds the closest possible segment to the given point within the maximum distance
  /// Checks the entire segment length, not just endpoints
  SegmentInRoute? _findClosestPossibleSegment(LatLng point, {double maxDistance = 20.0}) {
    SegmentInRoute? closestPossibleSegment;
    double minDistance = double.infinity;

    for (final possibleSegment in _possibleSegments) {
      // Use calcDistanceToSegment to find closest point anywhere along the segment
      final distance = possibleSegment.segment.calcDistanceToSegment(point, maxDistanceToCheck: maxDistance);
      if (distance != null && distance < minDistance) {
        minDistance = distance;
        closestPossibleSegment = possibleSegment;
      }
    }

    return closestPossibleSegment;
  }

  /// Determine the new start point after adding a segment to the route
  LatLng _getNewStartPoint(SegmentInRoute segmentInRoute) {
    // Use the stored direction to determine which point to use
    return segmentInRoute.direction == 'forward' 
        ? LatLng(segmentInRoute.segment.endLat, segmentInRoute.segment.endLng)
        : LatLng(segmentInRoute.segment.startLat, segmentInRoute.segment.startLng);
  }

  Future<void> _handleMapClick(LatLng point) async {
    if (_currentState == _CreateState.awaitingStartPoint) {
      // First click - set start point and find possible segments
      _startPoint = point;
      await _calculatePossibleSegments(point);
      _currentState = _CreateState.awaitingFirstSegment;
    } else {
      // Check if we clicked near a possible segment
      final closestPossibleSegment = _findClosestPossibleSegment(point);
      
      if (closestPossibleSegment != null) {
        // Clicked near a possible segment - add it to route
        _routeSegments.add(closestPossibleSegment);
        uiContext.routeSidebarService.setSegments(_routeSegments);
        
        // Move start point to the opposite end of the added segment
        _startPoint = _getNewStartPoint(closestPossibleSegment);
        
        // Recalculate possible segments from new start point
        await _calculatePossibleSegments(_startPoint!);
        
        // Center map on new start point
        uiContext.mapViewService.centerOnPoint(_startPoint!);
        
        _currentState = _CreateState.awaitingNextSegment;
      } else {
        // Clicked away from possible segments - reset start point
        _startPoint = point;
        await _calculatePossibleSegments(point);
        _currentState = _CreateState.awaitingFirstSegment;
      }
    }
    
    _updateMapContent();
    _updateStatusBar();
  }

  Future<void> _handleSegmentSelected(Segment segment) async {
    // Just zoom to show the segment
    final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    uiContext.mapViewService.mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
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
        _possibleSegments = [];
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
