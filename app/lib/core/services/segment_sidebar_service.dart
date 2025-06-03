import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/segment.dart';
import '../services/segment_service.dart';
import '../services/mode_service.dart';
import '../widgets/segment_sidebar.dart';
import '../../main.dart';

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

  /// Select a segment and optionally scroll to it
  void selectSegment(Segment segment, {bool shouldScroll = false}) {
    _selectedSegment = segment;
    
    // Emit event to current mode controller
    final modeService = Provider.of<ModeService>(navigatorKey.currentContext!, listen: false);
    modeService.currentMode?.handleEvent('segment_selected', segment);
    
    notifyListeners();
    
    if (shouldScroll) {
      scrollToSegment(segment);
    }
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

  /// Scroll to make a segment visible in the sidebar
  void scrollToSegment(Segment segment) {
    // Find the index of the segment in the filtered list
    final index = segments.indexWhere((s) => s.id == segment.id);
    if (index != -1) {
      // Get the SegmentSidebar state using the global key
      final state = SegmentSidebar.globalKey.currentState;
      if (state != null) {
        state.scrollToIndex(index);
      }
    }
  }
} 