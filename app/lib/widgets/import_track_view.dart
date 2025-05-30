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
                  Expanded(
                    flex: 2,
                    child: ImportMapView(
                      onPointSelected: (index) => importService.selectPoint(index),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          child: importService.currentTrack != null
                              ? ImportTrackFilenamePanel(
                                  filename: importService.currentTrack!.name,
                                  onClose: () => importService.clearTrack(),
                                  onInfo: () => importService.showSegmentOptionsDialog(context),
                                )
                              : ImportTrackFilenamePanel(
                                  filename: 'No file selected',
                                  onClose: () {},
                                  onInfo: () {},
                                  showOpenButton: true,
                                ),
                        ),
                        Expanded(
                          child: importService.track != null
                              ? const ImportTrackSegmentList()
                              : const Center(
                                  child: Text('No track loaded'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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