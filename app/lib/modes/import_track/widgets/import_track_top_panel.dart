// Top panel widget for the import track view that displays file information and controls.
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../services/gpx_service.dart';
import '../widgets/import_track_options_dialog.dart';
import '../models/track_import_options.dart';

class ImportTrackTopPanel extends StatelessWidget {
  const ImportTrackTopPanel({super.key});

  Future<void> _importGpxFile(BuildContext context) async {
    final typeGroup = XTypeGroup(
      label: 'GPX',
      extensions: ['gpx'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null && context.mounted) {
      final importService = context.read<ImportService>();
      
      // Parse and import the track
      final track = await GpxService.parseGpxFile(file.path);
      if (context.mounted) {
        importService.setTrack(track);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final state = importService.state;
    final statusMessage = importService.statusMessage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          if (importService.track != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                importService.clearTrack();
              },
              tooltip: 'Close',
            ),
          Expanded(
            child: Row(
              children: [
                Text(
                  importService.track?.name ?? 'No file selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (importService.track == null)
                  TextButton(
                    onPressed: () => _importGpxFile(context),
                    child: const Text('Open...'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              statusMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
          if (state == ImportState.segmentSelected) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                importService.deleteCurrentSelection();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                importService.createSegment();
              },
              child: const Text('Save'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Segment Options',
              onPressed: () {
                importService.showSegmentOptionsDialog(context);
              },
            ),
          ],
        ],
      ),
    );
  }
} 