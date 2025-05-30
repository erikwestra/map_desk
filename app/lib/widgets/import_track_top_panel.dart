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
      
      // Show import options dialog
      final options = await showDialog<TrackImportOptions>(
        context: context,
        builder: (context) => ImportTrackOptionsDialog(
          initialOptions: importService.importOptions,
        ),
      );

      // If dialog was cancelled, return
      if (options == null || !context.mounted) return;

      // Update import options
      importService.setImportOptions(options);

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
    final track = importService.importedTrack;

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
          if (track != null)
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
                  track?.name ?? 'No file selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (track == null)
                  TextButton(
                    onPressed: () => _importGpxFile(context),
                    child: const Text('Open...'),
                  ),
              ],
            ),
          ),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 