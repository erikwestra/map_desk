// Handles track import workflow, split mode, and segment creation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/gpx_track.dart';
import '../models/segment.dart';

class ImportService extends ChangeNotifier {
  GpxTrack? _importedTrack;
  bool _isSplitMode = false;
  final List<Segment> _segments = [];
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  ImportService();

  GpxTrack? get importedTrack => _importedTrack;
  bool get isTrackLoaded => _importedTrack != null;
  bool get isSplitMode => _isSplitMode;
  List<Segment> get segments => List.unmodifiable(_segments);
  MapController get mapController => _mapController;
  List<LatLng> get trackPoints => _importedTrack?.points.map((p) => p.toLatLng()).toList() ?? [];

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

  void setTrack(GpxTrack track) {
    _importedTrack = track;
    _isSplitMode = false;
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _importedTrack = null;
    _isSplitMode = false;
    notifyListeners();
  }

  void toggleSplitMode() {
    _isSplitMode = !_isSplitMode;
    notifyListeners();
  }

  void addSegment(Segment segment) {
    _segments.add(segment);
    notifyListeners();
  }

  void removeSegment(Segment segment) {
    _segments.remove(segment);
    notifyListeners();
  }

  void clearSegments() {
    _segments.clear();
    notifyListeners();
  }

  void zoomToTrackBounds() {
    if (!_isMapReady || _importedTrack == null || _importedTrack!.points.isEmpty) return;
    try {
      final points = _importedTrack!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
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