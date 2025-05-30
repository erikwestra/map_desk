// Handles track import workflow, split mode, and segment creation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/simple_gpx_track.dart';
import '../models/splittable_gpx_track.dart';
import '../models/segment.dart';
import '../models/segment_import_options.dart';
import '../widgets/import_segment_options_dialog.dart';

enum ImportState {
  noFile,
  fileLoaded,
  endpointSelected,
  segmentSelected,
}

class ImportService extends ChangeNotifier {
  SplittableGpxTrack? _track;
  final List<Segment> _segments = [];
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  SegmentImportOptions _importOptions = SegmentImportOptions.defaults();
  String _statusMessage = '';
  ImportState _state = ImportState.noFile;
  int _currentSegmentNumber = 1;

  ImportService();

  SplittableGpxTrack? get track => _track;
  bool get isTrackLoaded => _track != null;
  List<Segment> get segments => List.unmodifiable(_segments);
  MapController get mapController => _mapController;
  List<LatLng> get trackPoints => _track?.points.map((p) => p.toLatLng()).toList() ?? [];
  SegmentImportOptions get importOptions => _importOptions;
  int? get startPointIndex => _track?.startPointIndex;
  int? get endPointIndex => _track?.endPointIndex;
  List<LatLng> get selectedPoints => _track?.selectedPoints ?? [];
  List<LatLng> get unselectedPoints {
    if (_track == null) return [];
    
    final allPoints = _track!.points.map((p) => p.toLatLng()).toList();
    final selected = _track!.selectedPoints;
    
    // If we have a start point but no end point, include all points after the start
    if (_track!.startPointIndex != null && _track!.endPointIndex == null) {
      return allPoints.sublist(_track!.startPointIndex!);
    }
    
    // If we have both start and end points, include all points after the end
    if (_track!.startPointIndex != null && _track!.endPointIndex != null) {
      return allPoints.sublist(_track!.endPointIndex!);
    }
    
    // Otherwise return all points that aren't in the selected set
    return allPoints.where((p) => !selected.contains(p)).toList();
  }
  String get statusMessage => _statusMessage;
  ImportState get state => _state;
  int get currentSegmentNumber => _currentSegmentNumber;

  void _updateStatusMessage() {
    switch (_state) {
      case ImportState.noFile:
        _statusMessage = '';
        break;
      case ImportState.fileLoaded:
        _statusMessage = 'Click on one end of the track to start splitting';
        break;
      case ImportState.endpointSelected:
        final baseName = _importOptions.segmentName.isEmpty 
          ? 'Segment'
          : _importOptions.segmentName;
        _statusMessage = 'Click on endpoint to create segment $baseName $_currentSegmentNumber';
        break;
      case ImportState.segmentSelected:
        final baseName = _importOptions.segmentName.isEmpty 
          ? 'Segment'
          : _importOptions.segmentName;
        _statusMessage = '$baseName $_currentSegmentNumber';
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

  void setTrack(SimpleGpxTrack simpleTrack) {
    _track = SplittableGpxTrack(
      name: simpleTrack.name,
      points: simpleTrack.points,
      description: simpleTrack.description,
    );
    _state = ImportState.fileLoaded;
    _importOptions = SegmentImportOptions.defaults();
    _currentSegmentNumber = 1;
    _updateStatusMessage();
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _track = null;
    _state = ImportState.noFile;
    _importOptions = SegmentImportOptions.defaults();
    _currentSegmentNumber = 1;
    _updateStatusMessage();
    notifyListeners();
  }

  void setImportOptions(SegmentImportOptions options) {
    // Only reset the segment number if the base name (without number) has changed
    final currentBaseName = _importOptions.segmentName.replaceAll(RegExp(r'\s+\d+$'), '');
    final newBaseName = options.segmentName.replaceAll(RegExp(r'\s+\d+$'), '');
    
    if (currentBaseName != newBaseName) {
      _currentSegmentNumber = 1;
    }
    
    _importOptions = options;
    _updateStatusMessage();
    notifyListeners();
  }

  Future<void> showSegmentOptionsDialog(BuildContext context) async {
    final options = await showDialog<SegmentImportOptions>(
      context: context,
      builder: (context) => ImportSegmentOptionsDialog(
        initialOptions: _importOptions,
      ),
    );

    if (options != null && context.mounted) {
      setImportOptions(options);
    }
  }

  void selectPoint(int index) {
    if (_track == null) return;
    
    switch (_state) {
      case ImportState.fileLoaded:
        // In fileLoaded state, we can only select first or last point as start point
        if (index == 0 || index == _track!.points.length - 1) {
          _track!.selectStartPoint(index);
          _state = ImportState.endpointSelected;
          _updateStatusMessage();
          notifyListeners();
        }
        break;
        
      case ImportState.endpointSelected:
        // If we have a start point but no end point, select it
        if (_track!.startPointIndex != null) {
          _track!.selectEndPoint(index);
          _state = ImportState.segmentSelected;
          _updateStatusMessage();
          notifyListeners();
        }
        break;
        
      case ImportState.segmentSelected:
        // In segmentSelected state, we can select a new end point
        if (_track!.startPointIndex != null) {
          _track!.selectEndPoint(index);
          _updateStatusMessage();
          notifyListeners();
        }
        break;
        
      case ImportState.noFile:
        // Do nothing in noFile state
        break;
    }
  }

  void clearSelection() {
    if (_track == null) return;
    _track!.clearSelection();
    _state = ImportState.fileLoaded;
    _updateStatusMessage();
    notifyListeners();
  }

  void deleteCurrentSelection() {
    if (_track == null || _track!.startPointIndex == null || _track!.endPointIndex == null) return;
    
    // Get the end index of the segment to be deleted
    final endIndex = _track!.endPointIndex!;
    
    // Remove all points up to and including the end point
    _track!.removePointsUpTo(endIndex);
    
    // Clear the selection
    _track!.clearSelection();
    
    // Set state to endpointSelected and select the first point
    _state = ImportState.endpointSelected;
    _track!.selectStartPoint(0);
    
    _updateStatusMessage();
    notifyListeners();
  }

  void addSegment(Segment segment) {
    _segments.add(segment);
    _state = ImportState.segmentSelected;
    _currentSegmentNumber++;
    _updateStatusMessage();
    notifyListeners();
  }

  void removeSegment(Segment segment) {
    _segments.remove(segment);
    _state = ImportState.fileLoaded;
    _updateStatusMessage();
    notifyListeners();
  }

  void clearSegments() {
    _segments.clear();
    _state = ImportState.fileLoaded;
    _currentSegmentNumber = 1;
    _updateStatusMessage();
    notifyListeners();
  }

  void createSegment() {
    if (_track == null || _track!.startPointIndex == null || _track!.endPointIndex == null) {
      return;
    }

    final points = _track!.points.map((p) => SegmentPoint(
      latitude: p.latitude,
      longitude: p.longitude,
      elevation: p.elevation,
    )).toList();
    
    final newSegment = Segment.fromPoints(
      name: _importOptions.segmentName.isEmpty 
        ? 'Segment $_currentSegmentNumber'
        : '${_importOptions.segmentName} $_currentSegmentNumber',
      allPoints: points,
      startIndex: _track!.startPointIndex!,
      endIndex: _track!.endPointIndex!,
      direction: _importOptions.direction == SegmentDirection.oneWay ? 'oneWay' : 'bidirectional',
    );
    
    addSegment(newSegment);
  }

  LatLngBounds? calculateTrackEndpointsBounds() {
    if (_track == null || _track!.points.isEmpty) return null;
    
    // Get first and last points
    final firstPoint = _track!.points.first.toLatLng();
    final lastPoint = _track!.points.last.toLatLng();
    
    // Create bounds rectangle
    final bounds = LatLngBounds.fromPoints([firstPoint, lastPoint]);
    
    // Calculate the center point
    final center = LatLng(
      (bounds.north + bounds.south) / 2,
      (bounds.east + bounds.west) / 2,
    );
    
    // Calculate the size of the bounds
    final latSpan = bounds.north - bounds.south;
    final lngSpan = bounds.east - bounds.west;
    
    // Expand by 10%
    final expandedLatSpan = latSpan * 1.1;
    final expandedLngSpan = lngSpan * 1.1;
    
    // Create new expanded bounds
    return LatLngBounds(
      LatLng(center.latitude - expandedLatSpan / 2, center.longitude - expandedLngSpan / 2),
      LatLng(center.latitude + expandedLatSpan / 2, center.longitude + expandedLngSpan / 2),
    );
  }

  void zoomToTrackBounds() {
    if (!_isMapReady || _track == null || _track!.points.isEmpty) return;
    try {
      final bounds = calculateTrackEndpointsBounds();
      if (bounds != null) {
        _mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
      }
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