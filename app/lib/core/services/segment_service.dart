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
      final List<Map<String, dynamic>> maps = await db.query(
        'segments',
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return Segment.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to fetch segments: $e');
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
      return Segment.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to fetch segment: $e');
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
      await db.update(
        'segments',
        segment.toMap(),
        where: 'id = ?',
        whereArgs: [segment.id],
      );
    } catch (e) {
      throw Exception('Failed to update segment: $e');
    }
  }

  /// Creates a new segment in the database
  Future<int> createSegment(Segment segment) async {
    try {
      final db = await _database.database;
      return await db.insert('segments', segment.toMap());
    } catch (e) {
      throw Exception('Failed to create segment: $e');
    }
  }
} 