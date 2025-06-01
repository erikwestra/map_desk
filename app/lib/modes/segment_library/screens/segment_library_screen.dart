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
class SegmentLibraryScreen extends StatelessWidget {
  const SegmentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentLibraryService>(
      builder: (context, service, _) {
        return Row(
          children: [
            // Sidebar with segment list
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  // Toolbar at the top
                  const SegmentLibraryToolbar(),
                  // Segment list below
                  const Expanded(
                    child: SegmentLibraryList(),
                  ),
                ],
              ),
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