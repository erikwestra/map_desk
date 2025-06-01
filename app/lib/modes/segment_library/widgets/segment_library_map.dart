import 'package:flutter/material.dart';
import 'package:map_desk/core/models/segment.dart';

/// Widget that displays the selected segment on the map.
class SegmentLibraryMap extends StatelessWidget {
  final Segment? selectedSegment;

  const SegmentLibraryMap({
    super.key,
    required this.selectedSegment,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedSegment == null) {
      return const Center(
        child: Text('Select a segment to view on map'),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Map view for "${selectedSegment!.name}"',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text('Map view coming soon...'),
        ],
      ),
    );
  }
} 