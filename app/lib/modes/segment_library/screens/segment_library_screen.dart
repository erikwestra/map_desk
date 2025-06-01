import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/segment.dart';
import '../../../core/services/segment_service.dart';
import '../services/segment_library_service.dart';
import '../widgets/segment_library_list.dart';
import '../widgets/segment_library_map.dart';
import '../widgets/segment_library_toolbar.dart';

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
  final double _maxSidebarWidth = 500.0;
  bool _isLoading = false;
  String? _error;

  void _showError(String message) {
    print('SegmentLibraryScreen: $message');
    setState(() {
      _error = message;
    });
  }

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
      _showError('Failed to load segments: $e');
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
      _showError('Failed to delete segment: $e');
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
      _showError('Failed to update segment: $e');
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
    return Stack(
      children: [
        Row(
          children: [
            SizedBox(
              width: _sidebarWidth,
              child: Stack(
                children: [
                  SegmentLibraryList(
                    segments: widget.segmentLibraryService.segments,
                    selectedSegment: widget.segmentLibraryService.selectedSegment,
                    onSegmentSelected: widget.segmentLibraryService.selectSegment,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _sidebarWidth = (_sidebarWidth + details.delta.dx)
                                .clamp(_minSidebarWidth, _maxSidebarWidth);
                          });
                        },
                        child: Container(
                          width: 8,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: Stack(
                children: [
                  SegmentLibraryMap(
                    selectedSegment: widget.segmentLibraryService.selectedSegment,
                  ),
                  if (widget.segmentLibraryService.selectedSegment != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: SegmentLibraryToolbar(
                        selectedSegment: widget.segmentLibraryService.selectedSegment!,
                        onDelete: () => _deleteSegment(widget.segmentLibraryService.selectedSegment!),
                        onUpdate: _updateSegment,
                      ),
                    ),
                ],
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
    );
  }
} 