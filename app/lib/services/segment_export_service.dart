// Service for handling segment exports to various formats
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import '../models/segment.dart';
import 'package:path/path.dart' as path;

class SegmentExportService {
  /// Exports segments to a GeoJSON file
  Future<void> exportToGeoJSON(List<Segment> segments) async {
    try {
      if (segments.isEmpty) {
        throw Exception('No segments to export');
      }

      // Convert segments to GeoJSON
      final geoJSON = _segmentsToGeoJSON(segments);
      
      // Get save location from user
      final saveLocation = await getSaveLocation(
        suggestedName: 'segments.geojson',
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'GeoJSON',
            extensions: ['geojson'],
          ),
        ],
      );
      
      if (saveLocation != null) {
        // Write GeoJSON to file
        final fileHandle = XFile.fromData(
          utf8.encode(jsonEncode(geoJSON)),
          name: path.basename(saveLocation.path),
          mimeType: 'application/json',
        );
        await fileHandle.saveTo(saveLocation.path);
      }
    } catch (e) {
      print('SegmentExportService: Failed to export segments: $e');
      rethrow;
    }
  }

  /// Converts a list of segments to GeoJSON format
  Map<String, dynamic> _segmentsToGeoJSON(List<Segment> segments) {
    return {
      'type': 'FeatureCollection',
      'features': segments.map(_segmentToGeoJSON).toList(),
    };
  }

  /// Converts a single segment to GeoJSON feature
  Map<String, dynamic> _segmentToGeoJSON(Segment segment) {
    return {
      'type': 'Feature',
      'properties': {
        'id': segment.id,
        'name': segment.name,
        'direction': segment.direction,
      },
      'geometry': {
        'type': 'LineString',
        'coordinates': segment.points.map((point) => [
          point.longitude,
          point.latitude,
          if (point.elevation != null) point.elevation,
        ]).toList(),
      },
    };
  }
} 