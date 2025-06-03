import 'package:flutter/material.dart';
import '../models/segment.dart';
import '../services/segment_service.dart';

/// Service that manages the state of the segment sidebar.
class SegmentSidebarService extends ChangeNotifier {
  final SegmentService _segmentService;
  Segment? _selectedSegment;
  bool _isExpanded = true;
  List<Segment> _segments = [];
  String _searchQuery = '';

  SegmentSidebarService(this._segmentService) {
    _loadSegments();
  }

  // Getters
  Segment? get selectedSegment => _selectedSegment;
  bool get isExpanded => _isExpanded;
  List<Segment> get segments => _searchQuery.isEmpty 
      ? _segments 
      : _segments.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  /// Load segments from the database
  Future<void> _loadSegments() async {
    try {
      _segments = await _segmentService.getAllSegments();
      notifyListeners();
    } catch (e) {
      print('SegmentSidebarService: Failed to load segments: $e');
    }
  }

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

  /// Update the search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear the search query
  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Refresh the segments list
  Future<void> refreshSegments() async {
    await _loadSegments();
  }
} 