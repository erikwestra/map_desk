import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/segment.dart';
import '../models/gpx_track.dart';
import 'package:latlong2/latlong.dart';

/// Service for handling database operations
class DatabaseService {
  static const String _databaseName = 'segments.db';
  static const int _databaseVersion = 1;
  
  static Database? _database;
  
  /// Get the database instance, creating it if necessary
  Future<Database> get database async {
    print('DatabaseService: Getting database instance');
    if (_database != null) {
      print('DatabaseService: Using existing database instance');
      return _database!;
    }
    print('DatabaseService: Initializing new database instance');
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    print('DatabaseService: Initializing database');
    // Get the application support directory
    final appSupportDir = await getApplicationSupportDirectory();
    final dbPath = join(appSupportDir.path, 'databases', _databaseName);
    print('DatabaseService: Database path: $dbPath');
    
    // Ensure the databases directory exists
    await getDatabasesPath().then((path) async {
      final dir = Directory(join(path, '..'));
      if (!await dir.exists()) {
        print('DatabaseService: Creating databases directory');
        await dir.create(recursive: true);
      }
    });

    print('DatabaseService: Opening database connection');
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    print('DatabaseService: Creating database tables (version $version)');
    await db.execute('''
      CREATE TABLE segments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        points TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    print('DatabaseService: Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DatabaseService: Upgrading database from version $oldVersion to $newVersion');
    // Future migrations will be added here
    print('DatabaseService: Database upgrade completed');
  }

  /// Save a segment to the database
  Future<void> saveSegment(Segment segment) async {
    print('DatabaseService: Saving segment "${segment.name}" (ID: ${segment.id})');
    final db = await database;
    await db.insert(
      'segments',
      {
        'id': segment.id,
        'name': segment.name,
        'points': jsonEncode(segment.points.map((p) => {
          'latitude': p.latitude,
          'longitude': p.longitude,
          'elevation': p.elevation,
        }).toList()),
        'created_at': segment.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('DatabaseService: Segment saved successfully');
  }

  /// Get all segments from the database
  Future<List<Segment>> getAllSegments() async {
    print('DatabaseService: Fetching all segments');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('segments');
    print('DatabaseService: Found ${maps.length} segments');
    
    return List.generate(maps.length, (i) {
      final points = jsonDecode(maps[i]['points'] as String) as List;
      return Segment(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        points: points.map((p) => SegmentPoint(
          latitude: p['latitude'] as double,
          longitude: p['longitude'] as double,
          elevation: p['elevation'] as double?,
        )).toList(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at'] as int),
      );
    });
  }

  /// Get a segment by ID
  Future<Segment?> getSegment(String id) async {
    print('DatabaseService: Fetching segment with ID: $id');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'segments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      print('DatabaseService: No segment found with ID: $id');
      return null;
    }

    print('DatabaseService: Found segment with ID: $id');
    final points = jsonDecode(maps[0]['points'] as String) as List;
    return Segment(
      id: maps[0]['id'] as String,
      name: maps[0]['name'] as String,
      points: points.map((p) => SegmentPoint(
        latitude: p['latitude'] as double,
        longitude: p['longitude'] as double,
        elevation: p['elevation'] as double?,
      )).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(maps[0]['created_at'] as int),
    );
  }

  /// Delete a segment by ID
  Future<void> deleteSegment(String id) async {
    print('DatabaseService: Deleting segment with ID: $id');
    final db = await database;
    await db.delete(
      'segments',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('DatabaseService: Segment deleted successfully');
  }

  /// Delete all segments
  Future<void> deleteAllSegments() async {
    print('DatabaseService: Deleting all segments');
    final db = await database;
    await db.delete('segments');
    print('DatabaseService: All segments deleted successfully');
  }
} 