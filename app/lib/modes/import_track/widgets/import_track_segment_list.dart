// Import track segment list widget for displaying created segments
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../models/segment.dart';

class ImportTrackSegmentList extends StatelessWidget {
  const ImportTrackSegmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportService>(
      builder: (context, importService, _) {
        final segments = importService.segments;

        if (segments.isEmpty) {
          return const Center(
            child: Text('No segments created'),
          );
        }

        return ListView.builder(
          itemCount: segments.length,
          itemBuilder: (context, index) {
            final segment = segments[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(segment.name),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  visualDensity: VisualDensity.compact,
                  minVerticalPadding: 0,
                ),
                if (index < segments.length - 1)
                  const Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }
} 