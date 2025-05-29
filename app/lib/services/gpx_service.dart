import 'dart:io';
import 'package:xml/xml.dart';
import '../models/gpx_track.dart';

/// Service for parsing GPX files
class GpxService {
  /// Parse a GPX file and return a GpxTrack
  static Future<GpxTrack> parseGpxFile(String filePath) async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      return parseGpxString(contents, filePath);
    } catch (e) {
      throw GpxParseException('Failed to read file: $e');
    }
  }

  /// Parse GPX content from a string
  static GpxTrack parseGpxString(String gpxContent, String fileName) {
    try {
      final document = XmlDocument.parse(gpxContent);
      final gpxElement = document.findElements('gpx').first;
      
      // Extract track name
      String trackName = _extractTrackName(gpxElement, fileName);
      
      // Extract track points
      List<GpxPoint> points = _extractTrackPoints(gpxElement);
      
      if (points.isEmpty) {
        throw GpxParseException('No track points found in GPX file');
      }
      
      return GpxTrack(
        name: trackName,
        points: points,
        description: _extractDescription(gpxElement),
      );
    } catch (e) {
      if (e is GpxParseException) rethrow;
      throw GpxParseException('Invalid GPX format: $e');
    }
  }

  /// Extract track name from GPX
  static String _extractTrackName(XmlElement gpxElement, String fileName) {
    // Try to get track name from <trk><name>
    final trkElements = gpxElement.findElements('trk');
    if (trkElements.isNotEmpty) {
      final nameElement = trkElements.first.findElements('name');
      if (nameElement.isNotEmpty) {
        final name = nameElement.first.innerText.trim();
        if (name.isNotEmpty) return name;
      }
    }
    
    // Try to get metadata name
    final metadataElements = gpxElement.findElements('metadata');
    if (metadataElements.isNotEmpty) {
      final nameElement = metadataElements.first.findElements('name');
      if (nameElement.isNotEmpty) {
        final name = nameElement.first.innerText.trim();
        if (name.isNotEmpty) return name;
      }
    }
    
    // Fallback to filename
    return fileName.split('/').last.replaceAll('.gpx', '');
  }

  /// Extract description from GPX
  static String? _extractDescription(XmlElement gpxElement) {
    final trkElements = gpxElement.findElements('trk');
    if (trkElements.isNotEmpty) {
      final descElement = trkElements.first.findElements('desc');
      if (descElement.isNotEmpty) {
        final desc = descElement.first.innerText.trim();
        return desc.isNotEmpty ? desc : null;
      }
    }
    return null;
  }

  /// Extract all track points from GPX
  static List<GpxPoint> _extractTrackPoints(XmlElement gpxElement) {
    List<GpxPoint> points = [];
    
    // Find all track segments
    final trkElements = gpxElement.findElements('trk');
    for (final trk in trkElements) {
      final trksegElements = trk.findElements('trkseg');
      for (final trkseg in trksegElements) {
        final trkptElements = trkseg.findElements('trkpt');
        for (final trkpt in trkptElements) {
          final point = _parseTrackPoint(trkpt);
          if (point != null) {
            points.add(point);
          }
        }
      }
    }
    
    return points;
  }

  /// Parse a single track point
  static GpxPoint? _parseTrackPoint(XmlElement trkptElement) {
    try {
      final latStr = trkptElement.getAttribute('lat');
      final lonStr = trkptElement.getAttribute('lon');
      
      if (latStr == null || lonStr == null) return null;
      
      final lat = double.parse(latStr);
      final lon = double.parse(lonStr);
      
      // Parse optional elevation
      double? elevation;
      final eleElements = trkptElement.findElements('ele');
      if (eleElements.isNotEmpty) {
        try {
          elevation = double.parse(eleElements.first.innerText);
        } catch (e) {
          // Ignore elevation parsing errors
        }
      }
      
      // Parse optional time
      DateTime? time;
      final timeElements = trkptElement.findElements('time');
      if (timeElements.isNotEmpty) {
        try {
          time = DateTime.parse(timeElements.first.innerText);
        } catch (e) {
          // Ignore time parsing errors
        }
      }
      
      return GpxPoint(
        latitude: lat,
        longitude: lon,
        elevation: elevation,
        time: time,
      );
    } catch (e) {
      // Skip invalid points
      return null;
    }
  }
}

/// Exception thrown when GPX parsing fails
class GpxParseException implements Exception {
  final String message;
  
  const GpxParseException(this.message);
  
  @override
  String toString() => 'GPX Parse Error: $message';
} 