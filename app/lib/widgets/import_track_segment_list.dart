// Right-side panel widget for the import track view that displays a list of segments.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../models/segment.dart';

class ImportTrackSegmentList extends StatelessWidget {
  const ImportTrackSegmentList({super.key});

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final segments = importService.segments;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: segments.isEmpty
          ? Center(
              child: Text(
                'No segments created yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            )
          : ListView.builder(
              itemCount: segments.length,
              itemBuilder: (context, index) {
                final segment = segments[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentListItem(segment: segment),
                    if (index < segments.length - 1)
                      const Divider(height: 1),
                  ],
                );
              },
            ),
    );
  }
}

class _SegmentListItem extends StatelessWidget {
  final Segment segment;

  const _SegmentListItem({required this.segment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(segment.name),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
} 