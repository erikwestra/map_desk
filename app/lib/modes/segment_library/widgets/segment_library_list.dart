import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';

/// Widget that displays an alphabetical list of segments in the sidebar.
class SegmentLibraryList extends StatelessWidget {
  final List<Segment> segments;
  final Segment? selectedSegment;
  final Function(Segment) onSegmentSelected;

  const SegmentLibraryList({
    super.key,
    required this.segments,
    required this.selectedSegment,
    required this.onSegmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return Center(
        child: Text(
          'No segments found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        final isSelected = selectedSegment?.id == segment.id;

        return ListTile(
          title: Text(
            segment.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          selected: isSelected,
          onTap: () => onSegmentSelected(segment),
        );
      },
    );
  }
} 