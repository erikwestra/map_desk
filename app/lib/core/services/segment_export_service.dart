// Service for handling segment exports in various formats
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import '../models/segment.dart';
import 'package:path/path.dart' as path;

class SegmentExportService {
  /// Exports segments to a GeoJSON file
  Future<void> exportToGeoJSON(List<Segment> segments) async {
    try {
      // Convert segments to GeoJSON
      final geoJSON = _segmentsToGeoJSON(segments);
      
      // Convert to pretty-printed JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(geoJSON);
      
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
        // Write the file
        await XFile.fromData(
          utf8.encode(jsonString),
          name: path.basename(saveLocation.path),
          mimeType: 'application/geo+json',
        ).saveTo(saveLocation.path);
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

  /// Converts a single segment to GeoJSON Feature format
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
        'coordinates': segment.points.map((point) {
          // If elevation exists and is not null, include it
          if (point.elevation != null) {
            return [point.longitude, point.latitude, point.elevation];
          }
          // Otherwise just use 2D coordinates
          return [point.longitude, point.latitude];
        }).toList(),
      },
    };
  }
} 