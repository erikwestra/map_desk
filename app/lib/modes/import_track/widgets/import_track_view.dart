// Main view widget for track import workflow, combining selection panel, map preview, and status bar
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../models/selectable_item.dart';
import '../../../core/models/segment.dart';
import '../widgets/import_track_selection_panel.dart';
import '../widgets/import_track_status_bar.dart';
import '../widgets/import_track_map_view.dart';
import '../widgets/import_segment_map_view.dart';

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
                  // Selection panel
                  ImportTrackSelectionPanel(
                    items: importService.getSelectableItems(),
                    selectedId: importService.selectedItemId,
                    onItemSelected: (item) {
                      importService.selectItem(item.id);
                    },
                    onOpenFile: () => importService.importGpxFile(),
                    onCloseFile: () {
                      importService.clearTrack();
                    },
                  ),
                  // Main map area
                  Expanded(
                    child: _buildMapView(importService),
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

  Widget _buildMapView(ImportService importService) {
    final selectedItem = importService.selectedItem;
    
    if (selectedItem == null) {
      return const Center(child: Text('Select a track or segment'));
    }

    if (selectedItem.type == SelectableItemType.file) {
      return ImportTrackMapView(
        onPointSelected: (index) => importService.selectPoint(index),
      );
    } else {
      return ImportSegmentMapView(
        segment: selectedItem.data as Segment,
        mapController: importService.mapController,
      );
    }
  }
} 