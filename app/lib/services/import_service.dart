// Handles track import workflow, split mode, and segment creation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/simple_gpx_track.dart';
import '../models/splittable_gpx_track.dart';
import '../models/segment.dart';
import '../models/track_import_options.dart';

enum ImportState {
  noFile,
  fileLoaded,
  endpointSelected,
  segmentSelected,
}

class ImportService extends ChangeNotifier {
  SplittableGpxTrack? _importedTrack;
  bool _isSplitMode = false;
  final List<Segment> _segments = [];
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  TrackImportOptions _importOptions = TrackImportOptions.defaults();
  bool _isForwardDirection = true;
  String _statusMessage = '';
  ImportState _importState = ImportState.noFile;

  ImportService();

  SplittableGpxTrack? get importedTrack => _importedTrack;
  bool get isTrackLoaded => _importedTrack != null;
  bool get isSplitMode => _isSplitMode;
  List<Segment> get segments => List.unmodifiable(_segments);
  MapController get mapController => _mapController;
  List<LatLng> get trackPoints => _importedTrack?.points.map((p) => p.toLatLng()).toList() ?? [];
  TrackImportOptions get importOptions => _importOptions;
  bool get isForwardDirection => _isForwardDirection;
  int? get startPointIndex => _importedTrack?.startPointIndex;
  int? get endPointIndex => _importedTrack?.endPointIndex;
  List<LatLng> get selectedPoints => _importedTrack?.selectedPoints ?? [];
  List<LatLng> get unselectedPoints => _importedTrack == null ? [] : 
    _importedTrack!.points.map((p) => p.toLatLng()).toList()
      .where((p) => !_importedTrack!.selectedPoints.contains(p))
      .toList();
  String get statusMessage => _statusMessage;
  ImportState get importState => _importState;

  void _updateStatusMessage() {
    switch (_importState) {
      case ImportState.noFile:
        _statusMessage = '';
        break;
      case ImportState.fileLoaded:
        _statusMessage = 'Click on one end of the track to start splitting';
        break;
      case ImportState.endpointSelected:
        _statusMessage = 'Click on the other end of the segment';
        break;
      case ImportState.segmentSelected:
        _statusMessage = 'Segment Selected';
        break;
    }
  }

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
    _importState = ImportState.fileLoaded;
    _updateStatusMessage();
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _importedTrack = null;
    _isSplitMode = false;
    _importOptions = TrackImportOptions.defaults();
    _importState = ImportState.noFile;
    _updateStatusMessage();
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
      _importedTrack!.selectStartPoint(0);
    } else {
      _importedTrack!.selectStartPoint(_importedTrack!.points.length - 1);
    }
  }

  void selectPoint(int index) {
    if (_importedTrack == null) return;
    
    // If we don't have a start point, select it
    if (_importedTrack!.startPointIndex == null) {
      _importedTrack!.selectStartPoint(index);
      _importState = ImportState.endpointSelected;
    }
    // If we have a start point but no end point, select it
    else if (_importedTrack!.endPointIndex == null) {
      _importedTrack!.selectEndPoint(index);
      _importState = ImportState.segmentSelected;
    }
    
    _updateStatusMessage();
    notifyListeners();
  }

  void clearSelection() {
    if (_importedTrack == null) return;
    _importedTrack!.clearSelection();
    _importState = ImportState.fileLoaded;
    _updateStatusMessage();
    notifyListeners();
  }

  void toggleSplitMode() {
    _isSplitMode = !_isSplitMode;
    notifyListeners();
  }

  void addSegment(Segment segment) {
    _segments.add(segment);
    _importState = ImportState.segmentSelected;
    _updateStatusMessage();
    notifyListeners();
  }

  void removeSegment(Segment segment) {
    _segments.remove(segment);
    _importState = ImportState.fileLoaded;
    _updateStatusMessage();
    notifyListeners();
  }

  void clearSegments() {
    _segments.clear();
    _importState = ImportState.fileLoaded;
    _updateStatusMessage();
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