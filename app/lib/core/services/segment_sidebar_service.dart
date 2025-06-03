import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/segment.dart';
import '../models/sidebar_item.dart';
import '../services/segment_service.dart';
import '../services/mode_service.dart';
import '../widgets/segment_sidebar.dart';
import '../../main.dart';

/// Service that manages the state of the segment sidebar.
class SegmentSidebarService extends ChangeNotifier {
  final SegmentService _segmentService;
  SidebarItem? _selectedItem;
  bool _isExpanded = true;
  List<Segment> _segments = [];
  String _searchQuery = '';
  bool _showCurrentTrack = false;
  Segment? _currentTrack;
  bool _isEditable = true;  // Default to true for backward compatibility

  SegmentSidebarService(this._segmentService) {
    _loadSegments();
  }

  // Getters
  SidebarItem? get selectedItem => _selectedItem;
  bool get isExpanded => _isExpanded;
  bool get showCurrentTrack => _showCurrentTrack;
  Segment? get currentTrack => _currentTrack;
  List<Segment> get segments => _segments;
  bool get isEditable => _isEditable;
  
  // Get all items to display in the sidebar
  List<SidebarItem> get items {
    final items = <SidebarItem>[];
    
    // Add current track if enabled
    if (_showCurrentTrack) {
      items.add(SidebarItem(
        type: 'current_track',
        value: _currentTrack?.name ?? 'No track loaded',
        selectable: _currentTrack != null,  // Only selectable if there is a current track
      ));
    }
    
    // Add regular segments
    final filteredSegments = _searchQuery.isEmpty 
        ? _segments 
        : _segments.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    items.addAll(filteredSegments.map((s) => SidebarItem(
      type: 'segment',
      value: s,
      selectable: true,
    )));
    
    return items;
  }

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

  /// Select an item in the sidebar
  void selectItem(SidebarItem item) {
    if (!item.selectable) return;
    
    _selectedItem = item;
    
    // Emit appropriate event based on item type
    final modeService = Provider.of<ModeService>(navigatorKey.currentContext!, listen: false);
    if (item.type == 'current_track') {
      // Only emit track_selected if we have a current track
      if (_currentTrack != null) {
        modeService.currentMode?.handleEvent('track_selected', _currentTrack);
      }
    } else if (item.type == 'segment') {
      modeService.currentMode?.handleEvent('segment_selected', item.value);
    }
    
    notifyListeners();
  }

  /// Select a segment in the sidebar
  void selectSegment(Segment segment, {bool shouldScroll = false}) {
    final item = SidebarItem(
      type: 'segment',
      value: segment,
      selectable: true,
    );
    selectItem(item);
    if (shouldScroll) {
      scrollToItem(item);
    }
  }

  /// Get the currently selected segment
  Segment? get selectedSegment {
    if (_selectedItem?.type != 'segment') return null;
    return _selectedItem!.value as Segment;
  }

  /// Clear the selected item
  void clearSelection() {
    _selectedItem = null;
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

  /// Set whether to show the current track
  void setShowCurrentTrack(bool show) {
    _showCurrentTrack = show;
    notifyListeners();
  }

  /// Set the current track
  void setCurrentTrack(Segment? track) {
    _currentTrack = track;
    notifyListeners();
  }

  /// Scroll to make an item visible in the sidebar
  void scrollToItem(SidebarItem item) {
    // Find the index of the item in the list
    final index = items.indexWhere((i) => i.type == item.type && i.value == item.value);
    if (index != -1) {
      // Get the SegmentSidebar state using the global key
      final state = SegmentSidebar.globalKey.currentState;
      if (state != null) {
        state.scrollToIndex(index);
      }
    }
  }

  /// Set whether segments can be edited
  void setEditable(bool editable) {
    _isEditable = editable;
    notifyListeners();
  }
} 