// Manages map state, track visualization, and navigation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/simple_gpx_track.dart';

class MapService extends ChangeNotifier {
  SimpleGpxTrack? _currentTrack;
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  MapService();

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;
  MapController get mapController => _mapController;
  List<LatLng> get trackPoints => _currentTrack?.points.map((p) => p.toLatLng()).toList() ?? [];

  void setMapReady(bool ready) {
    _isMapReady = ready;
    if (ready && isTrackLoaded) {
      _scheduleZoomToTrackBounds();
    }
  }

  void _scheduleZoomToTrackBounds() {
    if (!_isMapReady) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMapReady) {
        zoomToTrackBounds();
      }
    });
  }

  void setTrack(SimpleGpxTrack track) {
    _currentTrack = track;
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _currentTrack = null;
    notifyListeners();
  }

  void zoomToTrackBounds() {
    if (!_isMapReady || _currentTrack == null || _currentTrack!.points.isEmpty) return;
    try {
      final points = _currentTrack!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
    } catch (e) {
      // If the map controller isn't ready yet, schedule another attempt
      _scheduleZoomToTrackBounds();
    }
  }

  void resetMapController() {
    _mapController.move(const LatLng(0, 0), 2.0);
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
} 