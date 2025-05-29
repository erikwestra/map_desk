import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/gpx_track.dart';

class MapService extends ChangeNotifier {
  GpxTrack? _currentTrack;
  MapController mapController = MapController();
  bool _isTrackLoaded = false;

  GpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _isTrackLoaded;

  void setTrack(GpxTrack track) {
    _currentTrack = track;
    _isTrackLoaded = true;
    
    // Calculate track bounds and fit map to them
    if (track.points.isNotEmpty) {
      final points = track.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      final bounds = LatLngBounds.fromPoints(points);
      mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)));
    }
    
    notifyListeners();
  }

  void clearTrack() {
    _currentTrack = null;
    _isTrackLoaded = false;
    notifyListeners();
  }

  List<LatLng> get trackPoints {
    if (_currentTrack == null) return [];
    return _currentTrack!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
} 