// Container widget that manages the complete track import and segment creation workflow.
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../services/gpx_service.dart';
import '../services/import_service.dart';
import '../services/view_service.dart';
import '../models/gpx_track.dart';
import '../models/segment.dart';
import 'import_map_view.dart';
import 'segment_splitter.dart';

class ImportTrackView extends StatefulWidget {
  const ImportTrackView({super.key});

  @override
  State<ImportTrackView> createState() => _ImportTrackViewState();
}

class _ImportTrackViewState extends State<ImportTrackView> {
  bool _isLoading = false;
  String? _errorMessage;
  int? _splitStartIndex;
  int? _splitEndIndex;

  @override
  void initState() {
    super.initState();
    // Start file picker immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _importGpxFile();
    });
  }

  Future<void> _importGpxFile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _splitStartIndex = null;
      _splitEndIndex = null;
    });

    try {
      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final track = await GpxService.parseGpxFile(file.path);
        context.read<ImportService>().setTrack(track);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _handleDone() {
    // Reset the map controller before switching views
    context.read<ImportService>().resetMapController();
    context.read<ViewService>().setView(ViewState.mapView);
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();
    final isSplitMode = importService.isTrackLoaded && importService.isSplitMode;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importGpxFile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (!importService.isTrackLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
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
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              if (importService.isTrackLoaded)
                TextButton(
                  onPressed: () {
                    importService.toggleSplitMode();
                  },
                  child: Text(
                    importService.isSplitMode ? 'Exit Split Mode' : 'Enter Split Mode',
                  ),
                ),
              TextButton(
                onPressed: _handleDone,
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 