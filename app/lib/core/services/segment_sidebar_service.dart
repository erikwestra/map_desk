import 'package:flutter/material.dart';
import '../models/segment.dart';
import '../services/segment_service.dart';

/// Service that manages the state of the segment sidebar.
class SegmentSidebarService extends ChangeNotifier {
  final SegmentService _segmentService;
  Segment? _selectedSegment;
  bool _isExpanded = true;

  SegmentSidebarService(this._segmentService);

  // Getters
  Segment? get selectedSegment => _selectedSegment;
  bool get isExpanded => _isExpanded;

  /// Toggle the sidebar expansion state
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Select a segment
  void selectSegment(Segment segment) {
    _selectedSegment = segment;
    notifyListeners();
  }

  /// Clear the selected segment
  void clearSelection() {
    _selectedSegment = null;
    notifyListeners();
  }

  /// Get all segments from the database
  Future<List<Segment>> getAllSegments() async {
    return _segmentService.getAllSegments();
  }
} 