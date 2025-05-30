// Handles track import workflow, split mode, and segment creation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/simple_gpx_track.dart';
import '../models/splittable_gpx_track.dart';
import '../models/segment.dart';
import '../models/track_import_options.dart';

class ImportService extends ChangeNotifier {
  SplittableGpxTrack? _importedTrack;
  bool _isSplitMode = false;
  final List<Segment> _segments = [];
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  TrackImportOptions _importOptions = TrackImportOptions.defaults();
  bool _isForwardDirection = true;
  String _statusMessage = '';

  ImportService();

  SplittableGpxTrack? get importedTrack => _importedTrack;
  bool get isTrackLoaded => _importedTrack != null;
  bool get isSplitMode => _isSplitMode;
  List<Segment> get segments => List.unmodifiable(_segments);
  MapController get mapController => _mapController;
  List<LatLng> get trackPoints => _importedTrack?.points.map((p) => p.toLatLng()).toList() ?? [];
  TrackImportOptions get importOptions => _importOptions;
  bool get isForwardDirection => _isForwardDirection;
  int? get selectedPointIndex => _importedTrack?.selectedPointIndex;
  List<LatLng> get selectedPoints => _importedTrack?.selectedPoints ?? [];
  List<LatLng> get unselectedPoints => _importedTrack == null ? [] : 
    _importedTrack!.points.map((p) => p.toLatLng()).toList()
      .where((p) => !_importedTrack!.selectedPoints.contains(p))
      .toList();
  String get statusMessage => _statusMessage;

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
    _importedTrack = SplittableGpxTrack(
      name: track.name,
      points: track.points,
      description: track.description,
    );
    _isSplitMode = false;
    _statusMessage = 'Click on one end of the track to start splitting';
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _importedTrack = null;
    _isSplitMode = false;
    _importOptions = TrackImportOptions.defaults();
    _statusMessage = '';
    notifyListeners();
  }

  void setImportOptions(TrackImportOptions options) {
    _importOptions = options;
    _isForwardDirection = options.trackDirection == TrackDirection.forward;
    if (_importedTrack != null) {
      _setInitialSelection();
    }
    notifyListeners();
  }

  void _setInitialSelection() {
    if (_importedTrack == null || !_importedTrack!.hasPoints) return;
    if (_isForwardDirection) {
      _importedTrack!.selectPoint(0);
    } else {
      _importedTrack!.selectPoint(_importedTrack!.points.length - 1);
    }
  }

  void selectPoint(int index) {
    if (_importedTrack == null) return;
    _importedTrack!.selectPoint(index);
    _statusMessage = 'Click on the other end of the track to create a segment';
    notifyListeners();
  }

  void clearSelection() {
    if (_importedTrack == null) return;
    _importedTrack!.clearSelection();
    _statusMessage = 'Click on one end of the track to start splitting';
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