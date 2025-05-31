import 'package:latlong2/latlong.dart';

/// Simple GPX Track data model for MapDesk
class SimpleGpxTrack {
  final String name;
  final List<GpxPoint> points;
  final String? description;
  int? _selectedPointIndex;
  List<LatLng> _selectedPoints = [];

  SimpleGpxTrack({
    required this.name,
    required this.points,
    this.description,
  });

  /// Get the number of track points
  int get pointCount => points.length;

  /// Check if the track has any points
  bool get hasPoints => points.isNotEmpty;

  /// Get basic track information as a string
  String get info {
    if (!hasPoints) return 'No track points';
    return '$pointCount track points';
  }

  /// Get the currently selected point index
  int? get selectedPointIndex => _selectedPointIndex;

  /// Get the list of selected points
  List<LatLng> get selectedPoints => List.unmodifiable(_selectedPoints);

  /// Select a point by index
  void selectPoint(int index) {
    if (index < 0 || index >= points.length) return;
    _selectedPointIndex = index;
    _updateSelectedPoints();
  }

  /// Clear the current selection
  void clearSelection() {
    _selectedPointIndex = null;
    _selectedPoints = [];
  }

  /// Get points before the selected index
  List<LatLng> getPointsBeforeIndex(int index) {
    if (index < 0 || index >= points.length) return [];
    return points.sublist(0, index + 1).map((p) => p.toLatLng()).toList();
  }

  /// Get points after the selected index
  List<LatLng> getPointsAfterIndex(int index) {
    if (index < 0 || index >= points.length) return [];
    return points.sublist(index).map((p) => p.toLatLng()).toList();
  }

  /// Update the selected points based on the current selection
  void _updateSelectedPoints() {
    if (_selectedPointIndex == null) {
      _selectedPoints = [];
      return;
    }
    _selectedPoints = getPointsBeforeIndex(_selectedPointIndex!);
  }
}

/// Individual point in a GPX track
class GpxPoint {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? time;

  const GpxPoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.time,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() {
    return 'GpxPoint(lat: $latitude, lon: $longitude, ele: $elevation)';
  }
} 