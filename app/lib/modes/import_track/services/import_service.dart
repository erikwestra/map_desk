// Service class managing track import workflow, segment creation, and state management for the import view
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_selector/file_selector.dart';
import '../../../core/models/simple_gpx_track.dart';
import '../../../core/models/splittable_gpx_track.dart';
import '../../../core/models/segment.dart';
import '../models/segment_import_options.dart';
import '../models/selectable_item.dart';
import '../widgets/import_track_options_dialog.dart';
import '../../../core/services/gpx_service.dart';

enum ImportState {
  noFile,
  startPointSelected,
  segmentSelected,
}

class ImportService extends ChangeNotifier {
  SplittableGpxTrack? _track;
  final List<Segment> _segments = [];
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  bool _hasZoomedToBounds = false;
  double _lastZoomLevel = 2.0;  // Default zoom level
  SegmentImportOptions _importOptions = SegmentImportOptions.defaults();
  String _statusMessage = '';
  ImportState _state = ImportState.noFile;
  int _currentSegmentNumber = 1;
  SimpleGpxTrack? _currentTrack;
  String _status = 'Ready to import track';
  bool _isProcessing = false;
  String? _selectedItemId;

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
  SimpleGpxTrack? get currentTrack => _currentTrack;
  String get status => _status;
  bool get isProcessing => _isProcessing;
  String? get selectedItemId => _selectedItemId;
  double get lastZoomLevel => _lastZoomLevel;  // Add getter for zoom level
  SelectableItem? get selectedItem {
    if (_selectedItemId == null) return null;
    return getSelectableItems().firstWhere(
      (item) => item.id == _selectedItemId,
      orElse: () => throw Exception('Selected item not found'),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<SelectableItem> getSelectableItems() {
    final items = <SelectableItem>[];
    
    // Add file item if we have a track
    if (_currentTrack != null) {
      items.add(SelectableItem.file(
        'file_${_currentTrack!.name}',
        _currentTrack!.name,
        _currentTrack!,
      ));
    }
    
    // Add segment items
    for (var segment in _segments) {
      items.add(SelectableItem.segment(
        'segment_${segment.name}',
        segment.name,
        segment,
      ));
    }
    
    return items;
  }

  void selectItem(String id) {
    _selectedItemId = id;
    
    // If selecting the track and we have a track loaded
    if (id.startsWith('file_') && _track != null) {
      if (!_hasZoomedToBounds) {
        // First time viewing the track, zoom to bounds
        _scheduleZoomToTrackBounds();
      } else {
        // Already zoomed before, pan to current start point or track center
        if (_track!.startPointIndex != null) {
          // If we have a start point, pan to it
          final point = _track!.points[_track!.startPointIndex!].toLatLng();
          _mapController.move(point, _lastZoomLevel);
        } else {
          // Otherwise pan to track center
          final bounds = calculateTrackEndpointsBounds();
          if (bounds != null) {
            _mapController.move(bounds.center, _lastZoomLevel);
          }
        }
      }
      // Update status message for track view
      _updateStatusMessage();
    } else if (id.startsWith('segment_')) {
      // Clear status message when viewing a segment
      _statusMessage = '';
      
      // Find the selected segment
      final segment = _segments.firstWhere(
        (s) => 'segment_${s.name}' == id,
        orElse: () => throw Exception('Selected segment not found'),
      );
      
      // Get the segment points
      final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      
      // Calculate bounds of the segment
      final bounds = LatLngBounds.fromPoints(points);
      
      // Fit the map to the segment bounds with padding
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
      
      // Store the zoom level after fitting bounds
      _lastZoomLevel = _mapController.zoom;
    }
    
    notifyListeners();
  }

  void _updateStatusMessage() {
    switch (_state) {
      case ImportState.noFile:
        _statusMessage = '';
        break;
      case ImportState.startPointSelected:
        _statusMessage = 'Click to select segment';
        break;
      case ImportState.segmentSelected:
        _statusMessage = 'Segment selected';
        break;
    }
  }

  void setMapReady(bool ready) {
    _isMapReady = ready;
    if (ready && isTrackLoaded && !_hasZoomedToBounds) {
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
    _track = SplittableGpxTrack(
      name: track.name,
      points: track.points,
      description: track.description,
    );
    _importOptions = SegmentImportOptions.defaults();
    _currentSegmentNumber = 1;
    _currentTrack = track;
    _status = 'Click to select segment';
    _isProcessing = false;
    _selectedItemId = 'file_${track.name}';
    _hasZoomedToBounds = false;  // Reset the flag when loading a new track
    
    // Automatically select the first point
    _track!.selectStartPoint(0);
    _state = ImportState.startPointSelected;
    _updateStatusMessage();
    
    // Only zoom to bounds when initially loading the file
    _scheduleZoomToTrackBounds();
    notifyListeners();
  }

  void clearTrack() {
    _track = null;
    _state = ImportState.noFile;
    _importOptions = SegmentImportOptions.defaults();
    _currentSegmentNumber = 1;
    _updateStatusMessage();
    _currentTrack = null;
    _status = 'Ready to import track';
    _isProcessing = false;
    _selectedItemId = null;
    _hasZoomedToBounds = false;  // Reset the flag when clearing the track
    notifyListeners();
  }

  void setImportOptions(SegmentImportOptions options) {
    _importOptions = options;
    _currentSegmentNumber = options.nextSegmentNumber;
    _updateStatusMessage();
    notifyListeners();
  }

  void selectPoint(int index) {
    if (_track == null) return;
    
    switch (_state) {
      case ImportState.startPointSelected:
        // If we have a start point but no end point, select it
        if (_track!.startPointIndex != null) {
          _track!.selectEndPoint(index);
          _state = ImportState.segmentSelected;
          _updateStatusMessage();
          // Pan to the selected point at current zoom
          _panToPoint(index);
          notifyListeners();
        }
        break;
        
      case ImportState.segmentSelected:
        // In segmentSelected state, we can select a new end point
        if (_track!.startPointIndex != null) {
          _track!.selectEndPoint(index);
          _updateStatusMessage();
          // Pan to the selected point at current zoom
          _panToPoint(index);
          notifyListeners();
        }
        break;
        
      case ImportState.noFile:
        // Do nothing in noFile state
        break;
    }
  }

  void _panToPoint(int index) {
    if (!_isMapReady || _track == null || index >= _track!.points.length) return;
    
    final point = _track!.points[index].toLatLng();
    _mapController.move(point, _lastZoomLevel);  // Use stored zoom level
  }

  Future<void> showSegmentOptionsDialog(BuildContext context) async {
    // Only show dialog if no segment name has been set
    if (_importOptions.segmentName.isEmpty) {
      // Calculate next segment number based on existing segments
      final nextNumber = await _calculateNextSegmentNumber();
      
      // Create new options with calculated next number
      final options = await showDialog<SegmentImportOptions>(
        context: context,
        builder: (context) => ImportTrackOptionsDialog(
          initialOptions: _importOptions.copyWith(nextSegmentNumber: nextNumber),
        ),
      );

      if (options != null && context.mounted) {
        setImportOptions(options);
      }
    }
  }

  Future<int> _calculateNextSegmentNumber() async {
    // Get all existing segments
    final existingSegments = _segments;
    
    // If no segments exist, start with 1
    if (existingSegments.isEmpty) {
      return 1;
    }
    
    // Extract numbers from segment names
    final numbers = <int>[];
    for (final segment in existingSegments) {
      final name = segment.name;
      // Try to extract number from name (e.g., "Segment 1" -> 1)
      final numberMatch = RegExp(r'\d+$').firstMatch(name);
      if (numberMatch != null) {
        final number = int.tryParse(numberMatch.group(0)!);
        if (number != null) {
          numbers.add(number);
        }
      }
    }
    
    // If no numbers found, start with 1
    if (numbers.isEmpty) {
      return 1;
    }
    
    // Return highest number + 1
    return numbers.reduce((a, b) => a > b ? a : b) + 1;
  }

  void clearSelection() {
    if (_track == null) return;
    _track!.clearSelection();
    _state = ImportState.startPointSelected;
    _track!.selectStartPoint(0);  // Automatically select first point
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
    
    // Set state to startPointSelected and select the first point
    _state = ImportState.startPointSelected;
    _track!.selectStartPoint(0);
    
    _updateStatusMessage();
    notifyListeners();
  }

  void cancelCurrentSelection() {
    if (_track == null || _track!.startPointIndex == null) return;
    
    // Remember the start point index
    final startIndex = _track!.startPointIndex!;
    
    // Clear the selection
    _track!.clearSelection();
    
    // Reselect the start point
    _track!.selectStartPoint(startIndex);
    
    // Set state to startPointSelected
    _state = ImportState.startPointSelected;
    
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
    _state = ImportState.startPointSelected;
    _track?.selectStartPoint(0);  // Automatically select first point
    _updateStatusMessage();
    notifyListeners();
  }

  void clearSegments() {
    _segments.clear();
    _state = ImportState.startPointSelected;
    _track?.selectStartPoint(0);  // Automatically select first point
    _currentSegmentNumber = 1;
    _updateStatusMessage();
    notifyListeners();
  }

  void createSegment(BuildContext context) async {
    if (_track == null || _track!.startPointIndex == null || _track!.endPointIndex == null) {
      return;
    }

    // If no segment name has been set, show the options dialog first
    if (_importOptions.segmentName.isEmpty) {
      // Calculate next segment number based on existing segments
      final nextNumber = await _calculateNextSegmentNumber();
      
      // Create new options with calculated next number
      final options = await showDialog<SegmentImportOptions>(
        context: context,
        builder: (context) => ImportTrackOptionsDialog(
          initialOptions: _importOptions.copyWith(nextSegmentNumber: nextNumber),
        ),
      );

      if (options == null || !context.mounted) {
        return; // User cancelled the dialog
      }
      
      setImportOptions(options);
    }

    final points = _track!.points.map((p) => SegmentPoint(
      latitude: p.latitude,
      longitude: p.longitude,
      elevation: p.elevation,
    )).toList();
    
    final segmentName = _importOptions.segmentName.isEmpty 
      ? 'Segment $_currentSegmentNumber'
      : '${_importOptions.segmentName} $_currentSegmentNumber';
    
    // Check if segment name already exists
    if (_segments.any((s) => s.name == segmentName)) {
      _showError(context, 'A segment with this name already exists. Please choose a different name.');
      return;
    }
    
    final newSegment = Segment.fromPoints(
      name: segmentName,
      allPoints: points,
      startIndex: _track!.startPointIndex!,
      endIndex: _track!.endPointIndex!,
      direction: _importOptions.direction == SegmentDirection.oneWay ? 'oneWay' : 'bidirectional',
    );
    
    addSegment(newSegment);

    // Remove the saved segment from the track
    final endIndex = _track!.endPointIndex!;
    _track!.removePointsUpTo(endIndex);
    
    // Clear the selection
    _track!.clearSelection();
    
    // Set state to startPointSelected and select the first point
    _state = ImportState.startPointSelected;
    _track!.selectStartPoint(0);
    
    _updateStatusMessage();
    notifyListeners();
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
        _hasZoomedToBounds = true;
        _lastZoomLevel = _mapController.zoom;  // Store the zoom level after fitting bounds
      }
    } catch (e) {
      // If the map controller isn't ready yet, schedule another attempt
      _scheduleZoomToTrackBounds();
    }
  }

  void resetMapController() {
    _mapController.move(const LatLng(0, 0), 2.0);
    _lastZoomLevel = 2.0;  // Reset stored zoom level
    notifyListeners();
  }

  void setProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    if (isProcessing) {
      _status = 'Processing track...';
    }
    notifyListeners();
  }

  Future<void> importGpxFile(BuildContext context) async {
    final typeGroup = XTypeGroup(
      label: 'GPX',
      extensions: ['gpx'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      try {
        setProcessing(true);
        final track = await GpxService.parseGpxFile(file.path);
        setTrack(track);
      } catch (e) {
        _showError(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
} 