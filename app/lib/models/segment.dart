import 'dart:convert';
import 'gpx_track.dart';

/// A segment represents a named section of a track that can be saved and reused
class Segment {
  final String id;
  final String name;
  final List<GpxPoint> points;
  final DateTime createdAt;

  const Segment({
    required this.id,
    required this.name,
    required this.points,
    required this.createdAt,
  });

  /// Create a new segment from a list of points
  factory Segment.fromPoints({
    required String name,
    required List<GpxPoint> points,
  }) {
    return Segment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: points,
      createdAt: DateTime.now(),
    );
  }

  /// Convert segment to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
        'elevation': point.elevation,
        'time': point.time?.toIso8601String(),
      }).toList(),
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create a segment from JSON data
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['points'] as List).map((pointJson) => GpxPoint(
        latitude: pointJson['latitude'] as double,
        longitude: pointJson['longitude'] as double,
        elevation: pointJson['elevation'] as double?,
        time: pointJson['time'] != null 
          ? DateTime.parse(pointJson['time'] as String)
          : null,
      )).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
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

  @override
  String toString() {
    return 'Segment(id: $id, name: $name, points: $pointCount)';
  }
} 