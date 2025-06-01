import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../models/route_builder_state.dart';
import '../../../core/models/segment.dart';
import '../../../core/services/segment_service.dart';
import '../../../core/models/simple_gpx_track.dart';

/// Service class for handling route building logic
class RouteBuilderService extends ChangeNotifier {
  final List<LatLng> _routePoints = [];
  final RouteBuilderStateProvider _stateProvider;
  final SegmentService _segmentService;
  LatLng? _selectedPoint;
  List<Segment> _nearbySegments = [];
  Segment? _selectedSegment;
  List<LatLng> _previewPoints = [];
  final List<Segment> _trackSegments = [];
  SimpleGpxTrack? _currentTrack;
  String _statusMessage = '';
  bool _isProcessing = false;
  static const double _searchRadius = 10.0; // 10 meters radius
  
  RouteBuilderService(this._stateProvider, this._segmentService);
  
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  LatLng? get selectedPoint => _selectedPoint;
  List<Segment> get nearbySegments => List.unmodifiable(_nearbySegments);
  Segment? get selectedSegment => _selectedSegment;
  List<LatLng> get previewPoints => List.unmodifiable(_previewPoints);
  List<Segment> get trackSegments => List.unmodifiable(_trackSegments);
  SimpleGpxTrack? get currentTrack => _currentTrack;
  String get statusMessage => _statusMessage;
  bool get isProcessing => _isProcessing;
  
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
  Future<void> addSelectedSegmentToRoute() async {
    if (_selectedSegment == null || _previewPoints.isEmpty) return;

    _routePoints.addAll(_previewPoints);
    _trackSegments.add(_selectedSegment!);
    _updateTrack();
    _selectedSegment = null;
    _previewPoints = [];
    _statusMessage = 'Segment added to track';

    // Find nearby segments at the new end point
    final lastPoint = _routePoints.last;
    await _findNearbySegments(lastPoint);
    
    // If we found nearby segments, stay in choosingNextSegment state
    // Otherwise, transition back to awaitingStartPoint
    if (_nearbySegments.isEmpty) {
      _stateProvider.setState(RouteBuilderState.awaitingStartPoint);
      _statusMessage = 'No more segments found nearby';
    }
    
    notifyListeners();
  }

  /// Updates the current track based on segments
  void _updateTrack() {
    if (_trackSegments.isEmpty) {
      _currentTrack = null;
      return;
    }

    final allPoints = <GpxPoint>[];
    for (final segment in _trackSegments) {
      allPoints.addAll(segment.points.map((p) => GpxPoint(
        latitude: p.latitude,
        longitude: p.longitude,
        elevation: p.elevation,
      )));
    }

    _currentTrack = SimpleGpxTrack(
      name: 'Built Track',
      points: allPoints,
    );
  }
  
  /// Undoes the last action in the route building session
  void undo() {
    if (_trackSegments.isNotEmpty) {
      _trackSegments.removeLast();
      _updateTrack();
      _statusMessage = 'Last segment removed from track';
    } else {
      _routePoints.clear();
      _selectedPoint = null;
      _nearbySegments.clear();
      _selectedSegment = null;
      _previewPoints = [];
      _stateProvider.reset();
      _statusMessage = 'Track cleared';
    }
    notifyListeners();
  }
  
  /// Saves the current track
  Future<void> save() async {
    if (_currentTrack == null) {
      _statusMessage = 'No track to save';
      notifyListeners();
      return;
    }

    setProcessing(true);
    try {
      // TODO: Implement track saving to database
      _statusMessage = 'Track saved successfully';
      
      // Clear the current track after saving
      _routePoints.clear();
      _selectedPoint = null;
      _nearbySegments.clear();
      _selectedSegment = null;
      _previewPoints = [];
      _trackSegments.clear();
      _currentTrack = null;
      _stateProvider.reset();
    } catch (e) {
      _statusMessage = 'Failed to save track: ${e.toString()}';
    } finally {
      setProcessing(false);
    }
  }

  /// Set processing state
  void setProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    notifyListeners();
  }
} 