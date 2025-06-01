import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_map.dart';

/// Widget that displays an alphabetical list of segments in the sidebar.
class SegmentLibraryList extends StatelessWidget {
  const SegmentLibraryList({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentLibraryService>();
    final segments = service.segments;
    final selectedSegment = service.selectedSegment;

    print('Selected segment ID: ${selectedSegment?.id}');

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
        
        print('Segment ${segment.id}: isSelected = $isSelected');

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
            print('Tapped segment ${segment.id}');
            service.selectSegment(segment);
          },
          trailing: isSelected ? IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ) : null,
        );
      },
    );
  }
} 