import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../models/route_builder_state.dart';
import '../../../core/models/segment.dart';
import '../../../core/services/segment_service.dart';

/// Service class for handling route building logic
class RouteBuilderService extends ChangeNotifier {
  final List<LatLng> _routePoints = [];
  final RouteBuilderStateProvider _stateProvider;
  final SegmentService _segmentService;
  LatLng? _selectedPoint;
  List<Segment> _nearbySegments = [];
  Segment? _selectedSegment;
  List<LatLng> _previewPoints = [];
  static const double _searchRadius = 10.0; // 10 meters radius
  
  RouteBuilderService(this._stateProvider, this._segmentService);
  
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  LatLng? get selectedPoint => _selectedPoint;
  List<Segment> get nearbySegments => List.unmodifiable(_nearbySegments);
  Segment? get selectedSegment => _selectedSegment;
  List<LatLng> get previewPoints => List.unmodifiable(_previewPoints);
  
  /// Handles map tap events based on current state
  Future<void> handleMapTap(LatLng point) async {
    switch (_stateProvider.currentState) {
      case RouteBuilderState.awaitingStartPoint:
        await _handleStartPointSelection(point);
        break;
      case RouteBuilderState.choosingNextSegment:
        // Ignore taps in choosingNextSegment state
        break;
    }
  }
  
  /// Handles the selection of a starting point
  Future<void> _handleStartPointSelection(LatLng point) async {
    _selectedPoint = point;
    _routePoints.add(point);
    await _findNearbySegments(point);
    
    // Only transition to choosingNextSegment if we found nearby segments
    if (_nearbySegments.isNotEmpty) {
      _stateProvider.setState(RouteBuilderState.choosingNextSegment);
    } else {
      // Clear the selected point and route points if no segments found
      _selectedPoint = null;
      _routePoints.clear();
    }
    
    notifyListeners();
  }
  
  /// Finds segments within the search radius of a point
  Future<void> _findNearbySegments(LatLng point) async {
    final allSegments = await _segmentService.getAllSegments();
    final Distance distance = Distance();
    
    _nearbySegments = allSegments.where((segment) {
      // For one-way segments: only include if first point is within radius
      if (segment.direction == 'one-way') {
        final firstPoint = LatLng(
          segment.points.first.latitude,
          segment.points.first.longitude,
        );
        return distance.as(LengthUnit.Meter, point, firstPoint) <= _searchRadius;
      }
      
      // For bidirectional segments: include if either first or last point is within radius
      final firstPoint = LatLng(
        segment.points.first.latitude,
        segment.points.first.longitude,
      );
      final lastPoint = LatLng(
        segment.points.last.latitude,
        segment.points.last.longitude,
      );
      
      return distance.as(LengthUnit.Meter, point, firstPoint) <= _searchRadius ||
             distance.as(LengthUnit.Meter, point, lastPoint) <= _searchRadius;
    }).toList();
  }

  /// Selects a segment and generates preview points
  void selectSegment(Segment segment) {
    _selectedSegment = segment;
    _generatePreviewPoints();
    notifyListeners();
  }

  /// Generates preview points for the selected segment
  void _generatePreviewPoints() {
    if (_selectedSegment == null) {
      _previewPoints = [];
      return;
    }

    final segment = _selectedSegment!;
    final lastRoutePoint = _routePoints.last;
    final Distance distance = Distance();

    // Convert segment points to LatLng
    final segmentPoints = segment.points.map((p) => 
      LatLng(p.latitude, p.longitude)
    ).toList();

    // For one-way segments, only use the points in order
    if (segment.direction == 'one-way') {
      _previewPoints = segmentPoints;
      return;
    }

    // For bidirectional segments, determine which direction to use
    final firstPoint = segmentPoints.first;
    final lastPoint = segmentPoints.last;

    // Use the direction that's closer to the last route point
    if (distance.as(LengthUnit.Meter, lastRoutePoint, firstPoint) <
        distance.as(LengthUnit.Meter, lastRoutePoint, lastPoint)) {
      _previewPoints = segmentPoints;
    } else {
      _previewPoints = segmentPoints.reversed.toList();
    }
  }

  /// Adds the selected segment to the route
  void addSelectedSegmentToRoute() {
    if (_selectedSegment == null || _previewPoints.isEmpty) return;

    _routePoints.addAll(_previewPoints);
    _selectedSegment = null;
    _previewPoints = [];
    notifyListeners();
  }
  
  /// Undoes the last action in the route building session
  void undo() {
    _routePoints.clear();
    _selectedPoint = null;
    _nearbySegments.clear();
    _selectedSegment = null;
    _previewPoints = [];
    _stateProvider.reset();
    notifyListeners();
  }
  
  /// Saves the current route
  void save() {
    // TODO: Implement route saving logic
    _routePoints.clear();
    _selectedPoint = null;
    _nearbySegments.clear();
    _selectedSegment = null;
    _previewPoints = [];
    _stateProvider.reset();
    notifyListeners();
  }
} 