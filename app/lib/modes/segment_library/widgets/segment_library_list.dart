import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_map.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_edit_dialog.dart';

/// Widget that displays an alphabetical list of segments in the sidebar.
class SegmentLibraryList extends StatelessWidget {
  const SegmentLibraryList({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentLibraryService>();
    final segments = service.segments;
    final selectedSegment = service.selectedSegment;

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
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          onTap: () {
            service.selectSegment(segment);
          },
          trailing: isSelected ? IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => SegmentLibraryEditDialog(segment: segment),
              );

              if (result == 'delete') {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Segment'),
                    content: const Text('Are you sure you want to delete this segment?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await service.deleteSegment(segment);
                }
              } else if (result != null) {
                // Update segment with new values
                final updatedSegment = segment.copyWith(
                  name: result['name'] as String,
                  direction: result['direction'] as String,
                );
                await service.updateSegment(updatedSegment);
              }
            },
          ) : null,
        );
      },
    );
  }
} 