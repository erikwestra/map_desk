// Main view widget for track import workflow, combining filename panel, map preview, segment splitter, and status bar
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../widgets/import_track_filename_panel.dart';
import '../widgets/import_track_status_bar.dart';
import '../widgets/import_track_segment_list.dart';
import '../widgets/import_map_view.dart';

class ImportTrackView extends StatelessWidget {
  const ImportTrackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportService>(
      builder: (context, importService, _) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Left sidebar
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Filename panel at the top
                        ImportTrackFilenamePanel(
                          filename: importService.currentTrack?.name ?? 'No file selected',
                          onClose: () => importService.clearTrack(),
                          onInfo: () => importService.showSegmentOptionsDialog(context),
                          showOpenButton: importService.currentTrack == null,
                        ),
                        // Divider
                        Container(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        // Segment list below
                        const Expanded(
                          child: ImportTrackSegmentList(),
                        ),
                      ],
                    ),
                  ),
                  // Main map area
                  Expanded(
                    child: ImportMapView(
                      onPointSelected: (index) => importService.selectPoint(index),
                    ),
                  ),
                ],
              ),
            ),
            // Status bar at the bottom
            ImportTrackStatusBar(
              status: importService.statusMessage,
              errorMessage: importService.errorMessage,
              isProcessing: importService.isProcessing,
            ),
          ],
        );
      },
    );
  }
} 