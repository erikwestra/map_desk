import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_library_service.dart';

/// Toolbar widget for the segment library, providing actions for selected segments.
class SegmentLibraryToolbar extends StatelessWidget {
  const SegmentLibraryToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentLibraryService>();
    final selectedSegment = service.selectedSegment;

    if (selectedSegment == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedSegment.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => service.deleteSegment(selectedSegment),
            tooltip: 'Delete segment',
          ),
        ],
      ),
    );
  }
} 