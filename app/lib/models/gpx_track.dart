import 'package:latlong2/latlong.dart';

/// GPX Track data model for MapDesk Phase 1
class GpxTrack {
  final String name;
  final List<GpxPoint> points;
  final String? description;

  const GpxTrack({
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