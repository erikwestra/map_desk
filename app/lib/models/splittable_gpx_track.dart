import 'package:latlong2/latlong.dart';
import 'simple_gpx_track.dart';

/// A GPX track that supports splitting and point selection functionality
class SplittableGpxTrack extends SimpleGpxTrack {
  int? _selectedPointIndex;
  List<LatLng> _selectedPoints = [];

  SplittableGpxTrack({
    required super.name,
    required super.points,
    super.description,
  });

  /// Get the currently selected point index
  int? get selectedPointIndex => _selectedPointIndex;

  /// Get the list of selected points
  List<LatLng> get selectedPoints => List.unmodifiable(_selectedPoints);

  /// Select a point by index
  void selectPoint(int index) {
    if (index < 0 || index >= points.length) return;
    _selectedPointIndex = index;
    _updateSelectedPoints();
  }

  /// Clear the current selection
  void clearSelection() {
    _selectedPointIndex = null;
    _selectedPoints = [];
  }

  /// Get points before the selected index
  List<LatLng> getPointsBeforeIndex(int index) {
    if (index < 0 || index >= points.length) return [];
    return points.sublist(0, index + 1).map((p) => p.toLatLng()).toList();
  }

  /// Get points after the selected index
  List<LatLng> getPointsAfterIndex(int index) {
    if (index < 0 || index >= points.length) return [];
    return points.sublist(index).map((p) => p.toLatLng()).toList();
  }

  /// Update the selected points based on the current selection
  void _updateSelectedPoints() {
    if (_selectedPointIndex == null) {
      _selectedPoints = [];
      return;
    }
    _selectedPoints = getPointsBeforeIndex(_selectedPointIndex!);
  }
} 