// Container widget that manages the complete track import and segment creation workflow.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../services/view_service.dart';
import '../models/segment.dart';
import 'import_map_view.dart';
import 'segment_splitter.dart';
import 'import_track_top_panel.dart';
import 'import_track_segment_list.dart';

class ImportTrackView extends StatefulWidget {
  const ImportTrackView({super.key});

  @override
  State<ImportTrackView> createState() => _ImportTrackViewState();
}

class _ImportTrackViewState extends State<ImportTrackView> {
  int? _splitStartIndex;
  int? _splitEndIndex;

  void _handlePointSelected(int index) {
    setState(() {
      if (_splitStartIndex == null) {
        _splitStartIndex = index;
      } else if (_splitEndIndex == null) {
        _splitEndIndex = index;
      } else {
        _splitStartIndex = index;
        _splitEndIndex = null;
      }
    });
  }

  void _handleCancel() {
    setState(() {
      _splitStartIndex = null;
      _splitEndIndex = null;
    });
  }

  void _handleSegmentCreated(Segment segment) {
    context.read<ImportService>().addSegment(segment);
    setState(() {
      _splitStartIndex = null;
      _splitEndIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final isSplitMode = importService.isTrackLoaded && importService.isSplitMode;

    return Column(
      children: [
        const ImportTrackTopPanel(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ImportMapView(
                      onPointSelected: isSplitMode ? _handlePointSelected : null,
                      splitStartIndex: _splitStartIndex,
                      splitEndIndex: _splitEndIndex,
                    ),
                    if (isSplitMode)
                      SegmentSplitter(
                        track: importService.importedTrack!,
                        onSegmentCreated: _handleSegmentCreated,
                        onCancel: _handleCancel,
                        startIndex: _splitStartIndex,
                        endIndex: _splitEndIndex,
                        onPointSelected: _handlePointSelected,
                      ),
                  ],
                ),
              ),
              const ImportTrackSegmentList(),
            ],
          ),
        ),
      ],
    );
  }
} 