import 'package:latlong2/latlong.dart';
import '../../../core/models/simple_gpx_track.dart';

/// A track that can be split into segments by selecting start and end points
class SelectableTrack {
  final SimpleGpxTrack track;
  int? _startPointIndex;
  int? _endPointIndex;

  SelectableTrack(this.track) {
    // Initialize with first point selected
    _startPointIndex = 0;
  }

  /// The index of the currently selected start point
  int? get startPointIndex => _startPointIndex;

  /// The index of the currently selected end point
  int? get endPointIndex => _endPointIndex;

  /// The points that are currently selected (between start and end)
  List<LatLng> get selectedPoints {
    if (_startPointIndex == null || _endPointIndex == null) return [];
    if (_startPointIndex! > _endPointIndex!) return [];
    return track.points
        .sublist(_startPointIndex!, _endPointIndex! + 1)
        .map((p) => p.toLatLng())
        .toList();
  }

  /// The points that are not currently selected
  List<LatLng> get unselectedPoints {
    if (_startPointIndex == null) {
      return track.points.map((p) => p.toLatLng()).toList();
    }

    if (_endPointIndex == null) {
      // If we have a start point but no end point, include all points after the start
      return track.points
          .sublist(_startPointIndex!)
          .map((p) => p.toLatLng())
          .toList();
    }

    // If we have both start and end points, include all points after the end
    return track.points
        .sublist(_endPointIndex! + 1)
        .map((p) => p.toLatLng())
        .toList();
  }

  /// Select a new start point
  void selectStartPoint(int index) {
    if (index < 0 || index >= track.points.length) {
      throw ArgumentError('Start point index out of range');
    }
    if (_endPointIndex != null && index > _endPointIndex!) {
      throw ArgumentError('Start point must be before end point');
    }
    _startPointIndex = index;
  }

  /// Select a new end point
  void selectEndPoint(int index) {
    if (index < 0 || index >= track.points.length) {
      throw ArgumentError('End point index out of range');
    }
    if (_startPointIndex != null && index < _startPointIndex!) {
      throw ArgumentError('End point must be after start point');
    }
    _endPointIndex = index;
  }

  /// Clear the current selection
  void clearSelection() {
    _startPointIndex = null;
    _endPointIndex = null;
  }

  /// Remove all points up to and including the given index
  void removePointsUpTo(int index) {
    if (index < 0 || index >= track.points.length) {
      throw ArgumentError('Index out of range');
    }
    track.points.removeRange(0, index + 1);
    _startPointIndex = null;
    _endPointIndex = null;
  }

  /// Clear only the end point selection
  void clearEndPoint() {
    _endPointIndex = null;
  }
} 