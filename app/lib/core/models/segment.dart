import 'dart:convert';
import 'package:latlong2/latlong.dart';

class SegmentPoint {
  final double latitude;
  final double longitude;
  final double? elevation;

  const SegmentPoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'elevation': elevation,
  };

  factory SegmentPoint.fromJson(Map<String, dynamic> json) => SegmentPoint(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    elevation: json['elevation'] as double?,
  );
}

/// A segment represents a named section of a track that can be saved and reused
class Segment {
  final String id;
  final String name;
  final List<SegmentPoint> points;
  final DateTime createdAt;
  final String direction;

  const Segment({
    required this.id,
    required this.name,
    required this.points,
    required this.createdAt,
    this.direction = 'bidirectional',
  });

  Segment copyWith({
    String? id,
    String? name,
    List<SegmentPoint>? points,
    DateTime? createdAt,
    String? direction,
  }) {
    return Segment(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      direction: direction ?? this.direction,
    );
  }

  /// Create a new segment from a list of points
  factory Segment.fromPoints({
    required String name,
    required List<SegmentPoint> allPoints,
    required int startIndex,
    required int endIndex,
    String direction = 'bidirectional',
  }) {
    return Segment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: allPoints.sublist(startIndex, endIndex + 1),
      createdAt: DateTime.now(),
      direction: direction,
    );
  }

  /// Convert segment to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => p.toJson()).toList(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'direction': direction,
    };
  }

  /// Create a segment from JSON data
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['points'] as List).map((p) => SegmentPoint.fromJson(p)).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      direction: json['direction'] as String? ?? 'bidirectional',
    );
  }

  /// Get the number of points in the segment
  int get pointCount => points.length;

  /// Check if the segment has any points
  bool get hasPoints => points.isNotEmpty;

  /// Get basic segment information as a string
  String get info {
    if (!hasPoints) return 'No points';
    return '$pointCount points';
  }

  /// Calculates the total distance of the segment in meters
  double get distance {
    if (points.length < 2) return 0;
    
    final Distance distance = Distance();
    double totalDistance = 0;
    
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += distance.as(
        LengthUnit.Meter,
        points[i].toLatLng(),
        points[i + 1].toLatLng(),
      );
    }
    
    return totalDistance;
  }

  /// Converts the segment to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points.map((p) => [p.latitude, p.longitude]).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a Segment from a Map
  factory Segment.fromMap(Map<String, dynamic> map) {
    return Segment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String,
      points: (map['points'] as List)
          .map((point) => SegmentPoint(
        latitude: point[0] as double,
        longitude: point[1] as double,
      ))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Segment(id: $id, name: $name, points: $pointCount)';
  }
} 