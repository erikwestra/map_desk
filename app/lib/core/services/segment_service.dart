import 'dart:convert';
import 'dart:math' as math;
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/core/services/database_service.dart';
import 'package:latlong2/latlong.dart';

/// Represents a bounding box for spatial search
class BoundingBox {
  final double left;
  final double right;
  final double top;
  final double bottom;

  const BoundingBox({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });
}

/// Core service responsible for all database operations related to segments.
/// This service provides a clean API for segment CRUD operations and handles
/// all database interactions.
class SegmentService {
  final DatabaseService _database;
  final Distance _distance = Distance();

  SegmentService(this._database);

  /// Calculates the bounding box for a given point and radius
  /// 
  /// [point] The center point of the search
  /// [radiusMeters] The search radius in meters
  /// Returns a [BoundingBox] containing the search area
  BoundingBox calculateBoundingBox(LatLng point, double radiusMeters) {
    // Convert radius from meters to degrees
    // At the equator, 1 degree of latitude is approximately 111,320 meters
    // 1 degree of longitude varies with latitude, so we use the cosine of the latitude
    final latDelta = radiusMeters / 111320.0;
    final lngDelta = radiusMeters / (111320.0 * math.cos(point.latitude * math.pi / 180.0));

    return BoundingBox(
      left: point.longitude - lngDelta,
      right: point.longitude + lngDelta,
      bottom: point.latitude - latDelta,
      top: point.latitude + latDelta,
    );
  }

  /// Checks if a point is within a specified distance of another point
  bool isWithinDistance(LatLng point1, LatLng point2, double distanceMeters) {
    return _distance.as(LengthUnit.Meter, point1, point2) <= distanceMeters;
  }

  /// Finds segments near a given point using a two-phase search strategy
  /// 
  /// [point] The center point of the search
  /// [radiusMeters] The search radius in meters (default: 10.0)
  /// Returns a list of segments that have start or end points within the radius
  Future<List<Segment>> findNearbySegments(LatLng point, {double radiusMeters = 10.0}) async {
    try {
      final db = await _database.database;
      
      // Phase 1: Bounding Box Search
      final bounds = calculateBoundingBox(point, radiusMeters);
      final candidates = await db.query(
        'segments',
        where: '''
          (start_lng >= ? AND start_lng <= ? AND start_lat >= ? AND start_lat <= ?)
          OR
          (end_lng >= ? AND end_lng <= ? AND end_lat >= ? AND end_lat <= ?)
        ''',
        whereArgs: [
          bounds.left, bounds.right, bounds.bottom, bounds.top,
          bounds.left, bounds.right, bounds.bottom, bounds.top,
        ],
      );

      // Phase 2: Precise Distance Check
      final matches = <Segment>[];
      for (final map in candidates) {
        final points = (jsonDecode(map['points'] as String) as List).map((pointJson) {
          return SegmentPoint(
            latitude: pointJson['latitude'] as double,
            longitude: pointJson['longitude'] as double,
            elevation: pointJson['elevation'] as double?,
          );
        }).toList();

        final segment = Segment(
          id: map['id'].toString(),
          name: map['name'] as String,
          points: points,
          direction: map['direction'] as String,
          startLat: map['start_lat'] as double,
          startLng: map['start_lng'] as double,
          endLat: map['end_lat'] as double,
          endLng: map['end_lng'] as double,
        );

        // For one-way segments, only check the starting point
        if (segment.direction != 'bidirectional') {
          if (isWithinDistance(point, LatLng(segment.startLat, segment.startLng), radiusMeters)) {
            matches.add(segment);
          }
        } else {
          // For bidirectional segments, check both start and end points
          if (isWithinDistance(point, LatLng(segment.startLat, segment.startLng), radiusMeters) ||
              isWithinDistance(point, LatLng(segment.endLat, segment.endLng), radiusMeters)) {
            matches.add(segment);
          }
        }
      }

      return matches;
    } catch (e) {
      throw Exception('Failed to find nearby segments: $e');
    }
  }

  /// Fetches all segments from the database, sorted alphabetically by name
  Future<List<Segment>> getAllSegments() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query('segments', orderBy: 'name ASC');
      return maps.map((map) {
        final points = (jsonDecode(map['points'] as String) as List).map((pointJson) {
          return SegmentPoint(
            latitude: pointJson['latitude'] as double,
            longitude: pointJson['longitude'] as double,
            elevation: pointJson['elevation'] as double?,
          );
        }).toList();

        return Segment(
          id: map['id'].toString(),
          name: map['name'] as String,
          points: points,
          direction: map['direction'] as String,
          startLat: map['start_lat'] as double,
          startLng: map['start_lng'] as double,
          endLat: map['end_lat'] as double,
          endLng: map['end_lng'] as double,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get segments: $e');
    }
  }

  /// Fetches a single segment by its ID
  Future<Segment?> getSegmentById(String id) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'segments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final map = maps.first;
      final points = (jsonDecode(map['points'] as String) as List).map((pointJson) {
        return SegmentPoint(
          latitude: pointJson['latitude'] as double,
          longitude: pointJson['longitude'] as double,
          elevation: pointJson['elevation'] as double?,
        );
      }).toList();

      return Segment(
        id: map['id'].toString(),
        name: map['name'] as String,
        points: points,
        direction: map['direction'] as String,
        startLat: map['start_lat'] as double,
        startLng: map['start_lng'] as double,
        endLat: map['end_lat'] as double,
        endLng: map['end_lng'] as double,
      );
    } catch (e) {
      throw Exception('Failed to get segment: $e');
    }
  }

  /// Deletes a segment from the database
  Future<void> deleteSegment(String id) async {
    try {
      final db = await _database.database;
      await db.delete(
        'segments',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete segment: $e');
    }
  }

  /// Updates a segment in the database
  Future<void> updateSegment(Segment segment) async {
    try {
      final db = await _database.database;
      final pointsJson = jsonEncode(segment.points.map((p) => {
        'latitude': p.latitude,
        'longitude': p.longitude,
        'elevation': p.elevation,
      }).toList());

      await db.update(
        'segments',
        {
          'name': segment.name,
          'points': pointsJson,
          'direction': segment.direction,
          'start_lat': segment.startLat,
          'start_lng': segment.startLng,
          'end_lat': segment.endLat,
          'end_lng': segment.endLng,
        },
        where: 'id = ?',
        whereArgs: [segment.id],
      );
    } catch (e) {
      throw Exception('Failed to update segment: $e');
    }
  }

  /// Creates a new segment in the database
  Future<Segment> createSegment(Segment segment) async {
    try {
      final db = await _database.database;
      final pointsJson = jsonEncode(segment.points.map((p) => {
        'latitude': p.latitude,
        'longitude': p.longitude,
        'elevation': p.elevation,
      }).toList());

      await db.insert(
        'segments',
        {
          'id': segment.id,
          'name': segment.name,
          'points': pointsJson,
          'direction': segment.direction,
          'start_lat': segment.startLat,
          'start_lng': segment.startLng,
          'end_lat': segment.endLat,
          'end_lng': segment.endLng,
        },
      );
      return segment;
    } catch (e) {
      throw Exception('Failed to create segment: $e');
    }
  }
} 