// Container widget that manages the complete track import and segment creation workflow.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/import_service.dart';
import '../services/view_service.dart';
import '../models/segment.dart';
import 'import_map_view.dart';
import 'import_track_top_panel.dart';
import 'import_track_segment_list.dart';

class ImportTrackView extends StatefulWidget {
  const ImportTrackView({super.key});

  @override
  State<ImportTrackView> createState() => _ImportTrackViewState();
}

class _ImportTrackViewState extends State<ImportTrackView> {
  void _handlePointSelected(int index) {
    context.read<ImportService>().selectPoint(index);
  }

  void _handleSegmentCreated(Segment segment) {
    context.read<ImportService>().addSegment(segment);
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();

    return Column(
      children: [
        const ImportTrackTopPanel(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ImportMapView(
                  onPointSelected: _handlePointSelected,
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