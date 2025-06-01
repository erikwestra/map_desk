import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_library_service.dart';
import '../widgets/segment_library_list.dart';
import '../widgets/segment_library_map.dart';

/// Main screen for the segment library feature.
/// Implements a split view with resizable sidebar and map area.
class SegmentLibraryScreen extends StatelessWidget {
  const SegmentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentLibraryService>(
      builder: (context, service, _) {
        if (!service.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (service.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading segments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  service.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => service.refreshSegments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Sidebar with segment list
            SizedBox(
              width: 300,
              child: const SegmentLibraryList(),
            ),
            // Vertical divider
            const VerticalDivider(width: 1),
            // Map area
            const Expanded(
              child: SegmentLibraryMap(),
            ),
          ],
        );
      },
    );
  }
} 