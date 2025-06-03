// Service for handling segment imports from various formats
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../models/segment.dart';
import 'database_service.dart';
import 'package:latlong2/latlong.dart';

class SegmentImportService {
  final DatabaseService _databaseService;

  SegmentImportService(this._databaseService);

  /// Imports segments from a GeoJSON file
  Future<void> importFromGeoJSON(BuildContext context) async {
    try {
      // Get file from user
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'GeoJSON',
            extensions: ['geojson'],
          ),
        ],
      );
      
      if (file != null) {
        // Read and parse the file
        final jsonString = await file.readAsString();
        final geoJSON = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Validate GeoJSON structure
        if (geoJSON['type'] != 'FeatureCollection') {
          throw FormatException('Invalid GeoJSON: expected FeatureCollection');
        }
        
        final features = geoJSON['features'] as List;
        final segments = <Segment>[];
        
        // Convert each feature to a segment
        for (final feature in features) {
          final segment = _featureToSegment(feature);
          if (segment != null) {
            segments.add(segment);
          }
        }

        // Ask user if they want to replace existing segments
        final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Segments'),
            content: const Text('Do you want to replace all existing segments with the imported ones?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Existing'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Replace All'),
              ),
            ],
          ),
        );

        if (shouldReplace == true) {
          // Delete all existing segments
          await _databaseService.deleteAllSegments();
        }
        
        // Save segments to database
        for (final segment in segments) {
          await _databaseService.saveSegment(segment);
        }
      }
    } catch (e) {
      print('SegmentImportService: Failed to import segments: $e');
      rethrow;
    }
  }

  /// Converts a GeoJSON feature to a Segment
  Segment? _featureToSegment(Map<String, dynamic> feature) {
    try {
      // Validate feature structure
      if (feature['type'] != 'Feature') {
        print('SegmentImportService: Invalid feature type: ${feature['type']}');
        return null;
      }

      final properties = feature['properties'] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;

      // Validate geometry
      if (geometry['type'] != 'LineString') {
        print('SegmentImportService: Unsupported geometry type: ${geometry['type']}');
        return null;
      }

      // Get coordinates
      final coordinates = geometry['coordinates'] as List;
      if (coordinates.isEmpty) {
        print('SegmentImportService: Empty coordinates list');
        return null;
      }

      // Convert coordinates to points
      final points = coordinates.map((coord) {
        final List<dynamic> coords = coord as List;
        return SegmentPoint(
          latitude: coords[1] as double,
          longitude: coords[0] as double,
          elevation: coords.length > 2 ? coords[2] as double? : null,
        );
      }).toList();

      // Calculate bounding box
      final bbox = Segment.calculateBoundingBox(points);

      // Create segment
      return Segment(
        id: properties['id'] as String,
        name: properties['name'] as String,
        direction: properties['direction'] as String,
        points: points,
        startLat: points.first.latitude,
        startLng: points.first.longitude,
        endLat: points.last.latitude,
        endLng: points.last.longitude,
        minLat: bbox.minLat,
        maxLat: bbox.maxLat,
        minLng: bbox.minLng,
        maxLng: bbox.maxLng,
      );
    } catch (e) {
      print('SegmentImportService: Failed to convert feature to segment: $e');
      return null;
    }
  }
} 