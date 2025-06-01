import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/core/services/segment_service.dart';

/// Service responsible for managing the segment library UI state.
/// Delegates all database operations to SegmentService.
class SegmentLibraryService extends ChangeNotifier {
  final SegmentService _segmentService;
  final MapController _mapController = MapController();
  List<Segment> _segments = [];
  Segment? _selectedSegment;
  double _lastZoomLevel = 2.0;
  bool _isLoading = false;
  String? _error;

  SegmentLibraryService(this._segmentService) {
    _loadSegments();
  }

  // Getters
  List<Segment> get segments => List.unmodifiable(_segments);
  Segment? get selectedSegment => _selectedSegment;
  MapController get mapController => _mapController;
  double get lastZoomLevel => _lastZoomLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _showError(String message) {
    print('SegmentLibraryService: $message');
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _loadSegments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final segments = await _segmentService.getAllSegments();
      _segments = segments;
    } catch (e) {
      _showError('Failed to load segments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSegment(Segment segment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _segmentService.deleteSegment(segment.id);
      _segments.remove(segment);
      if (_selectedSegment == segment) {
        _selectedSegment = null;
      }
    } catch (e) {
      _showError('Failed to delete segment: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSegment(Segment segment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _segmentService.updateSegment(segment);
      final index = _segments.indexWhere((s) => s.id == segment.id);
      if (index != -1) {
        _segments[index] = segment;
        if (_selectedSegment?.id == segment.id) {
          _selectedSegment = segment;
        }
      }
    } catch (e) {
      _showError('Failed to update segment: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a segment and zooms the map to it
  void selectSegment(Segment segment) {
    _selectedSegment = segment;
    
    // Calculate bounds of the segment
    final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    // Fit the map to the segment bounds with padding
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
    
    _lastZoomLevel = _mapController.zoom;
    notifyListeners();
  }

  /// Updates a segment in the list
  void updateSegmentInList(Segment segment) {
    final index = _segments.indexWhere((s) => s.id == segment.id);
    if (index != -1) {
      _segments[index] = segment;
      if (_selectedSegment?.id == segment.id) {
        _selectedSegment = segment;
      }
      notifyListeners();
    }
  }
} 