import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/core/services/segment_service.dart';

/// Service responsible for managing the segment library UI state.
/// Delegates all database operations to SegmentService.
class SegmentLibraryService {
  final SegmentService _segmentService;
  List<Segment> _segments = [];
  Segment? _selectedSegment;

  SegmentLibraryService(this._segmentService);

  // Getters
  List<Segment> get segments => List.unmodifiable(_segments);
  Segment? get selectedSegment => _selectedSegment;

  /// Updates the segments list
  void setSegments(List<Segment> segments) {
    _segments = segments;
  }

  /// Selects a segment
  void selectSegment(Segment segment) {
    _selectedSegment = segment;
  }

  /// Removes a segment from the list
  void removeSegment(Segment segment) {
    _segments.remove(segment);
    if (_selectedSegment == segment) {
      _selectedSegment = null;
    }
  }

  /// Updates a segment in the list
  void updateSegmentInList(Segment segment) {
    final index = _segments.indexWhere((s) => s.id == segment.id);
    if (index != -1) {
      _segments[index] = segment;
      if (_selectedSegment?.id == segment.id) {
        _selectedSegment = segment;
      }
    }
  }
} 