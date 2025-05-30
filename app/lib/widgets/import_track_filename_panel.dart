// Import track filename panel widget for displaying current track file information
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../services/gpx_service.dart';

class ImportTrackFilenamePanel extends StatelessWidget {
  final String filename;
  final VoidCallback onClose;
  final VoidCallback onInfo;
  final bool showOpenButton;

  const ImportTrackFilenamePanel({
    super.key,
    required this.filename,
    required this.onClose,
    required this.onInfo,
    this.showOpenButton = false,
  });

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              filename,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showOpenButton)
            TextButton(
              onPressed: () => _importGpxFile(context),
              child: const Text('Open...'),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: onInfo,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
} 