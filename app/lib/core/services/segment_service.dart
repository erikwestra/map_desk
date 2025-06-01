import 'dart:convert';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/core/services/database_service.dart';

/// Core service responsible for all database operations related to segments.
/// This service provides a clean API for segment CRUD operations and handles
/// all database interactions.
class SegmentService {
  final DatabaseService _database;

  SegmentService(this._database);

  /// Fetches all segments from the database, sorted alphabetically by name
  Future<List<Segment>> getAllSegments() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query('segments');
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