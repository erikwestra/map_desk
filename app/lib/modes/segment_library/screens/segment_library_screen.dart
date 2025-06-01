import 'package:flutter/material.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/core/services/segment_service.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_list.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_map.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_toolbar.dart';

/// Main screen for the segment library feature.
/// Implements a split view with resizable sidebar and map area.
class SegmentLibraryScreen extends StatefulWidget {
  final SegmentService segmentService;
  final SegmentLibraryService segmentLibraryService;

  const SegmentLibraryScreen({
    super.key,
    required this.segmentService,
    required this.segmentLibraryService,
  });

  @override
  State<SegmentLibraryScreen> createState() => _SegmentLibraryScreenState();
}

class _SegmentLibraryScreenState extends State<SegmentLibraryScreen> {
  double _sidebarWidth = 300.0;
  final double _minSidebarWidth = 200.0;
  final double _maxSidebarWidth = 400.0;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSegments();
  }

  Future<void> _loadSegments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final segments = await widget.segmentService.getAllSegments();
      widget.segmentLibraryService.setSegments(segments);
    } catch (e) {
      setState(() {
        _error = 'Failed to load segments: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSegment(Segment segment) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.segmentService.deleteSegment(segment.id);
      widget.segmentLibraryService.removeSegment(segment);
    } catch (e) {
      setState(() {
        _error = 'Failed to delete segment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSegment(Segment segment) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.segmentService.updateSegment(segment);
      widget.segmentLibraryService.updateSegmentInList(segment);
    } catch (e) {
      setState(() {
        _error = 'Failed to update segment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: _sidebarWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: SegmentLibraryList(
                        segments: widget.segmentLibraryService.segments,
                        selectedSegment: widget.segmentLibraryService.selectedSegment,
                        onSegmentSelected: (segment) {
                          widget.segmentLibraryService.selectSegment(segment);
                        },
                      ),
                    ),
                    if (widget.segmentLibraryService.selectedSegment != null)
                      SegmentLibraryToolbar(
                        selectedSegment: widget.segmentLibraryService.selectedSegment!,
                        onDelete: (segment) => _deleteSegment(segment),
                        onUpdate: (segment) => _updateSegment(segment),
                      ),
                  ],
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: SegmentLibraryMap(
                  selectedSegment: widget.segmentLibraryService.selectedSegment,
                ),
              ),
            ],
          ),
          if (_error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Theme.of(context).colorScheme.onError,
                        onPressed: _clearError,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _sidebarWidth = (_sidebarWidth + details.delta.dx)
                .clamp(_minSidebarWidth, _maxSidebarWidth);
          });
        },
        child: Container(
          width: 4,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
} 