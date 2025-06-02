// Status bar widget for displaying track processing status and error messages at the bottom of the import view
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';

class ImportTrackStatusBar extends StatelessWidget {
  final String status;
  final bool isProcessing;

  const ImportTrackStatusBar({
    super.key,
    required this.status,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final showSegmentButtons = importService.state == ImportState.segmentSelected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (showSegmentButtons) ...[
            TextButton(
              onPressed: () => importService.cancelCurrentSelection(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => importService.deleteCurrentSelection(),
              child: const Text('Delete'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => importService.createSegment(context),
              child: const Text('Save'),
            ),
          ],
        ],
      ),
    );
  }
} 