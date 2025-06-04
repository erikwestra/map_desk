import 'dart:io';
import 'package:xml/xml.dart';
import '../models/simple_gpx_track.dart';

/// Service for parsing GPX files
class GpxService {
  /// Parse a GPX file and return a SimpleGpxTrack
  static Future<SimpleGpxTrack> parseGpxFile(File file) async {
    try {
      final content = await file.readAsString();
      return parseGpxString(content, file.path);
    } catch (e) {
      throw GpxParseException('Failed to read GPX file: $e');
    }
  }

  /// Parse GPX content from a string
  static SimpleGpxTrack parseGpxString(String content, String filePath) {
    try {
      final document = XmlDocument.parse(content);
      final root = document.rootElement;
      
      if (root.name.local != 'gpx') {
        throw GpxParseException('Not a valid GPX file: root element is not "gpx"');
      }
      
      final trackName = _extractTrackName(root, filePath);
      final points = _extractTrackPoints(root);
      final description = _extractDescription(root);
      
      return SimpleGpxTrack(
        name: trackName,
        points: points,
        description: description,
      );
    } catch (e) {
      if (e is GpxParseException) rethrow;
      throw GpxParseException('Failed to parse GPX content: $e');
    }
  }

  /// Extract track name from GPX metadata or filename
  static String _extractTrackName(XmlElement root, String filePath) {
    // Try to get name from metadata
    final metadata = root.findElements('metadata').firstOrNull;
    if (metadata != null) {
      final name = metadata.findElements('name').firstOrNull;
      if (name != null && name.text.isNotEmpty) {
        return name.text;
      }
    }
    
    // Try to get name from track
    final track = root.findElements('trk').firstOrNull;
    if (track != null) {
      final name = track.findElements('name').firstOrNull;
      if (name != null && name.text.isNotEmpty) {
        return name.text;
      }
    }
    
    // Fallback to filename without extension
    final fileName = filePath.split('/').last;
    return fileName.replaceAll('.gpx', '');
  }

  /// Extract track points from GPX
  static List<GpxPoint> _extractTrackPoints(XmlElement root) {
    final points = <GpxPoint>[];
    
    for (final track in root.findElements('trk')) {
      for (final segment in track.findElements('trkseg')) {
        for (final point in segment.findElements('trkpt')) {
          final lat = double.parse(point.getAttribute('lat')!);
          final lon = double.parse(point.getAttribute('lon')!);
          
          double? elevation;
          final ele = point.findElements('ele').firstOrNull;
          if (ele != null) {
            elevation = double.tryParse(ele.text);
          }
          
          points.add(GpxPoint(
            latitude: lat,
            longitude: lon,
            elevation: elevation,
          ));
        }
      }
    }
    
    return points;
  }

  /// Extract description from GPX metadata
  static String? _extractDescription(XmlElement root) {
    final metadata = root.findElements('metadata').firstOrNull;
    if (metadata != null) {
      final desc = metadata.findElements('desc').firstOrNull;
      if (desc != null && desc.text.isNotEmpty) {
        return desc.text;
      }
    }
    
    final track = root.findElements('trk').firstOrNull;
    if (track != null) {
      final desc = track.findElements('desc').firstOrNull;
      if (desc != null && desc.text.isNotEmpty) {
        return desc.text;
      }
    }
    
    return null;
  }
}

/// Exception thrown when GPX parsing fails
class GpxParseException implements Exception {
  final String message;
  
  GpxParseException(this.message);
  
  @override
  String toString() => 'GpxParseException: $message';
} 