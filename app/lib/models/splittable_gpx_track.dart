import 'package:latlong2/latlong.dart';
import 'simple_gpx_track.dart';

/// A GPX track that supports splitting and point selection functionality
class SplittableGpxTrack extends SimpleGpxTrack {
  int? _startPointIndex;
  int? _endPointIndex;
  List<LatLng> _selectedPoints = [];

  SplittableGpxTrack({
    required super.name,
    required super.points,
    super.description,
  });

  /// Get the currently selected start point index
  int? get startPointIndex => _startPointIndex;

  /// Get the currently selected end point index
  int? get endPointIndex => _endPointIndex;

  /// Get the list of selected points between start and end
  List<LatLng> get selectedPoints => List.unmodifiable(_selectedPoints);

  /// Select a point as the start point
  void selectStartPoint(int index) {
    if (index < 0 || index >= points.length) return;
    _startPointIndex = index;
    _updateSelectedPoints();
  }

  /// Select a point as the end point
  void selectEndPoint(int index) {
    if (index < 0 || index >= points.length) return;
    _endPointIndex = index;
    _updateSelectedPoints();
  }

  /// Clear the current selection
  void clearSelection() {
    _startPointIndex = null;
    _endPointIndex = null;
    _selectedPoints = [];
  }

  /// Get points between start and end indices
  List<LatLng> getPointsBetweenIndices(int startIndex, int endIndex) {
    if (startIndex < 0 || endIndex >= points.length || startIndex > endIndex) return [];
    return points.sublist(startIndex, endIndex + 1).map((p) => p.toLatLng()).toList();
  }

  /// Update the selected points based on the current selection
  void _updateSelectedPoints() {
    if (_startPointIndex == null || _endPointIndex == null) {
      _selectedPoints = [];
      return;
    }
    _selectedPoints = getPointsBetweenIndices(_startPointIndex!, _endPointIndex!);
  }

  void removePointsUpTo(int endIndex) {
    if (endIndex < 0 || endIndex >= points.length) return;
    
    // Remove all points up to but not including the end index
    // This keeps the end point as the start of the remaining track
    points.removeRange(0, endIndex);
    
    // Reset selection
    clearSelection();
  }
} 