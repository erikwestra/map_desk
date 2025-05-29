import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/gpx_track.dart';
import '../models/segment.dart';

class MapService extends ChangeNotifier {
  final MapController mapController = MapController();
  GpxTrack? _track;
  bool _isSplitMode = false;
  List<Segment> _segments = [];

  bool get isTrackLoaded => _track != null;
  bool get isSplitMode => _isSplitMode;
  List<Segment> get segments => List.unmodifiable(_segments);
  List<LatLng> get trackPoints => _track?.points.map((p) => LatLng(p.latitude, p.longitude)).toList() ?? [];
  GpxTrack? get track => _track;

  void setTrack(GpxTrack track) {
    _track = track;
    _zoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _track = null;
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

  void _zoomToTrackBounds() {
    if (_track == null || _track!.points.isEmpty) return;
    final points = _track!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
  }
} 