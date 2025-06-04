import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/segment.dart';
import '../models/simple_gpx_track.dart';
import 'package:latlong2/latlong.dart';

/// Service for handling database operations
class DatabaseService {
  static const String _databaseName = 'segments.db';
  static const int _databaseVersion = 5; // Incremented for v020 migration
  
  static Database? _database;
  
  /// Get the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final dbDir = Directory(join(appSupportDir.path, 'databases'));
      
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      
      final dbPath = join(dbDir.path, _databaseName);
      return await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('DatabaseService: Failed to initialize database: $e');
      rethrow;
    }
  }

  /// Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE segments (
          id TEXT PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          points TEXT NOT NULL,
          direction TEXT NOT NULL DEFAULT 'bidirectional',
          start_lat REAL NOT NULL,
          start_lng REAL NOT NULL,
          end_lat REAL NOT NULL,
          end_lng REAL NOT NULL
        )
      ''');

      // Create indexes for spatial search
      await db.execute('CREATE INDEX idx_start_coords ON segments (start_lat, start_lng)');
      await db.execute('CREATE INDEX idx_end_coords ON segments (end_lat, end_lng)');
    } catch (e) {
      print('DatabaseService: Failed to create database tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        await _runMigration(db, 'v008', () async {
          await db.execute('''
            CREATE TABLE segments_new (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              points TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
          
          await db.execute('''
            INSERT INTO segments_new (id, name, points, created_at)
            SELECT id, name, points, created_at FROM segments
          ''');
          
          await db.execute('DROP TABLE segments');
          await db.execute('ALTER TABLE segments_new RENAME TO segments');
        });
      }
      
      if (oldVersion < 3) {
        await _runMigration(db, 'v011', () async {
          await db.execute('''
            CREATE TABLE segments_new (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              points TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              direction TEXT NOT NULL DEFAULT 'bidirectional'
            )
          ''');
          
          await db.execute('''
            INSERT INTO segments_new (id, name, points, created_at, direction)
            SELECT id, name, points, created_at, 'bidirectional' FROM segments
          ''');
          
          await db.execute('DROP TABLE segments');
          await db.execute('ALTER TABLE segments_new RENAME TO segments');
        });
      }

      if (oldVersion < 4) {
        await _runMigration(db, 'v013', () async {
          await db.execute('''
            CREATE TABLE segments_new (
              id TEXT PRIMARY KEY,
              name TEXT UNIQUE NOT NULL,
              points TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              direction TEXT NOT NULL DEFAULT 'bidirectional'
            )
          ''');
          
          final List<Map<String, dynamic>> existingSegments = await db.query('segments', orderBy: 'created_at ASC');
          
          final Set<String> usedNames = {};
          for (final segment in existingSegments) {
            String name = segment['name'] as String;
            int counter = 1;
            String originalName = name;
            
            while (usedNames.contains(name)) {
              name = '$originalName $counter';
              counter++;
            }
            
            usedNames.add(name);
            
            await db.insert('segments_new', {
              'id': segment['id'],
              'name': name,
              'points': segment['points'],
              'created_at': segment['created_at'],
              'direction': segment['direction'],
            });
          }
          
          await db.execute('DROP TABLE segments');
          await db.execute('ALTER TABLE segments_new RENAME TO segments');
        });
      }

      if (oldVersion < 5) {
        await _runMigration(db, 'v020', () async {
          await db.execute('''
            CREATE TABLE segments_new (
              id TEXT PRIMARY KEY,
              name TEXT UNIQUE NOT NULL,
              points TEXT NOT NULL,
              direction TEXT NOT NULL DEFAULT 'bidirectional',
              start_lat REAL NOT NULL,
              start_lng REAL NOT NULL,
              end_lat REAL NOT NULL,
              end_lng REAL NOT NULL
            )
          ''');

          // Create indexes for spatial search
          await db.execute('CREATE INDEX idx_start_coords ON segments_new (start_lat, start_lng)');
          await db.execute('CREATE INDEX idx_end_coords ON segments_new (end_lat, end_lng)');
          
          final List<Map<String, dynamic>> existingSegments = await db.query('segments');
          
          for (final segment in existingSegments) {
            final points = jsonDecode(segment['points'] as String) as List;
            if (points.isEmpty) continue;

            final firstPoint = points.first as Map<String, dynamic>;
            final lastPoint = points.last as Map<String, dynamic>;
            
            await db.insert('segments_new', {
              'id': segment['id'],
              'name': segment['name'],
              'points': segment['points'],
              'direction': segment['direction'],
              'start_lat': firstPoint['latitude'] as double,
              'start_lng': firstPoint['longitude'] as double,
              'end_lat': lastPoint['latitude'] as double,
              'end_lng': lastPoint['longitude'] as double,
            });
          }
          
          await db.execute('DROP TABLE segments');
          await db.execute('ALTER TABLE segments_new RENAME TO segments');
        });
      }
    } catch (e) {
      print('DatabaseService: Failed to upgrade database: $e');
      rethrow;
    }
  }

  /// Helper method to run migrations with proper error handling
  Future<void> _runMigration(Database db, String version, Future<void> Function() migration) async {
    try {
      await migration();
    } catch (e) {
      print('DatabaseService: Failed to run $version migration: $e');
      rethrow;
    }
  }

  /// Save a segment to the database
  Future<void> saveSegment(Segment segment) async {
    try {
      final db = await database;
      
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
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DatabaseService: Failed to save segment: $e');
      rethrow;
    }
  }

  /// Get all segments from the database
  Future<List<Segment>> getAllSegments() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('segments');
      
      return List.generate(maps.length, (i) {
        final points = jsonDecode(maps[i]['points'] as String) as List;
        final segmentPoints = points.map((p) => SegmentPoint(
          latitude: p['latitude'] as double,
          longitude: p['longitude'] as double,
          elevation: p['elevation'] as double?,
        )).toList();
        
        final bbox = Segment.calculateBoundingBox(segmentPoints);
        
        return Segment(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          points: segmentPoints,
          direction: maps[i]['direction'] as String,
          startLat: maps[i]['start_lat'] as double,
          startLng: maps[i]['start_lng'] as double,
          endLat: maps[i]['end_lat'] as double,
          endLng: maps[i]['end_lng'] as double,
          minLat: bbox.minLat,
          maxLat: bbox.maxLat,
          minLng: bbox.minLng,
          maxLng: bbox.maxLng,
        );
      });
    } catch (e) {
      print('DatabaseService: Failed to load segments: $e');
      rethrow;
    }
  }

  /// Get a segment by ID
  Future<Segment?> getSegment(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'segments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      final points = jsonDecode(maps[0]['points'] as String) as List;
      final segmentPoints = points.map((p) => SegmentPoint(
        latitude: p['latitude'] as double,
        longitude: p['longitude'] as double,
        elevation: p['elevation'] as double?,
      )).toList();
      
      final bbox = Segment.calculateBoundingBox(segmentPoints);
      
      return Segment(
        id: maps[0]['id'] as String,
        name: maps[0]['name'] as String,
        points: segmentPoints,
        direction: maps[0]['direction'] as String,
        startLat: maps[0]['start_lat'] as double,
        startLng: maps[0]['start_lng'] as double,
        endLat: maps[0]['end_lat'] as double,
        endLng: maps[0]['end_lng'] as double,
        minLat: bbox.minLat,
        maxLat: bbox.maxLat,
        minLng: bbox.minLng,
        maxLng: bbox.maxLng,
      );
    } catch (e) {
      print('DatabaseService: Failed to load segment: $e');
      rethrow;
    }
  }

  /// Delete a segment by ID
  Future<void> deleteSegment(String id) async {
    try {
      final db = await database;
      await db.delete(
        'segments',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('DatabaseService: Failed to delete segment: $e');
      rethrow;
    }
  }

  /// Delete all segments
  Future<void> deleteAllSegments() async {
    try {
      final db = await database;
      await db.delete('segments');
    } catch (e) {
      print('DatabaseService: Failed to delete all segments: $e');
      rethrow;
    }
  }
} 