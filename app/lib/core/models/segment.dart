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
  final String direction;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  // Bounding box properties
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  /// Calculates the bounding box for a list of points
  static ({double minLat, double maxLat, double minLng, double maxLng}) calculateBoundingBox(List<SegmentPoint> points) {
    return (
      minLat: points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
      maxLat: points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
      minLng: points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      maxLng: points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
    );
  }

  const Segment({
    required this.id,
    required this.name,
    required this.points,
    this.direction = 'bidirectional',
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  Segment copyWith({
    String? id,
    String? name,
    List<SegmentPoint>? points,
    String? direction,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) {
    return Segment(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      direction: direction ?? this.direction,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      minLat: minLat ?? this.minLat,
      maxLat: maxLat ?? this.maxLat,
      minLng: minLng ?? this.minLng,
      maxLng: maxLng ?? this.maxLng,
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
    final points = allPoints.sublist(startIndex, endIndex + 1);
    final bbox = calculateBoundingBox(points);

    return Segment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: points,
      direction: direction,
      startLat: points.first.latitude,
      startLng: points.first.longitude,
      endLat: points.last.latitude,
      endLng: points.last.longitude,
      minLat: bbox.minLat,
      maxLat: bbox.maxLat,
      minLng: bbox.minLng,
      maxLng: bbox.maxLng,
    );
  }

  /// Convert segment to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => p.toJson()).toList(),
      'direction': direction,
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'min_lat': minLat,
      'max_lat': maxLat,
      'min_lng': minLng,
      'max_lng': maxLng,
    };
  }

  /// Create a segment from JSON data
  factory Segment.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as List).map((p) => SegmentPoint.fromJson(p)).toList();
    final bbox = calculateBoundingBox(points);

    return Segment(
      id: json['id'] as String,
      name: json['name'] as String,
      points: points,
      direction: json['direction'] as String? ?? 'bidirectional',
      startLat: json['start_lat'] as double,
      startLng: json['start_lng'] as double,
      endLat: json['end_lat'] as double,
      endLng: json['end_lng'] as double,
      minLat: bbox.minLat,
      maxLat: bbox.maxLat,
      minLng: bbox.minLng,
      maxLng: bbox.maxLng,
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

  /// Checks if a point is within the segment's bounding box
  bool isPointInBoundingBox(LatLng point) {
    return point.latitude >= minLat &&
           point.latitude <= maxLat &&
           point.longitude >= minLng &&
           point.longitude <= maxLng;
  }

  /// Converts the segment to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points.map((p) => [p.latitude, p.longitude]).toList(),
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
    };
  }

  /// Creates a Segment from a Map
  factory Segment.fromMap(Map<String, dynamic> map) {
    final points = (map['points'] as List)
        .map((point) => SegmentPoint(
          latitude: point[0] as double,
          longitude: point[1] as double,
        ))
        .toList();

    final bbox = calculateBoundingBox(points);

    return Segment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String,
      points: points,
      direction: 'bidirectional',
      startLat: map['start_lat'] as double,
      startLng: map['start_lng'] as double,
      endLat: map['end_lat'] as double,
      endLng: map['end_lng'] as double,
      minLat: bbox.minLat,
      maxLat: bbox.maxLat,
      minLng: bbox.minLng,
      maxLng: bbox.maxLng,
    );
  }

  @override
  String toString() {
    return 'Segment(id: $id, name: $name, points: $pointCount)';
  }

  /// Compares two segments using natural sorting (e.g., "Test 1" comes before "Test 2" and "Test 10")
  static int compareByName(Segment a, Segment b) {
    // Split names into parts
    final aParts = a.name.split(' ');
    final bParts = b.name.split(' ');
    
    // Compare each part
    for (var i = 0; i < aParts.length && i < bParts.length; i++) {
      final aPart = aParts[i];
      final bPart = bParts[i];
      
      // Try to parse as numbers
      final aNum = int.tryParse(aPart);
      final bNum = int.tryParse(bPart);
      
      if (aNum != null && bNum != null) {
        // If both are numbers, compare numerically
        if (aNum != bNum) return aNum.compareTo(bNum);
      } else {
        // If either is not a number, compare as strings
        final comparison = aPart.compareTo(bPart);
        if (comparison != 0) return comparison;
      }
    }
    
    // If all parts match up to the length of the shorter name,
    // the shorter name comes first
    return aParts.length.compareTo(bParts.length);
  }
} 