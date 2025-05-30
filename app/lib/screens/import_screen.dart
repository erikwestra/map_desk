import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../services/gpx_service.dart';
import '../services/import_service.dart';
import '../models/simple_gpx_track.dart';
import '../models/segment.dart';
import '../widgets/import_map_view.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;
  String? _errorMessage;

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
    context.read<ImportService>().selectPoint(index);
  }

  void _handleDone() {
    // Reset the map controller before closing
    context.read<ImportService>().resetMapController();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.watch<ImportService>();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Track'),
        actions: [
          TextButton(
            onPressed: _handleDone,
            child: const Text('Done'),
          ),
        ],
      ),
      body: ImportMapView(
        onPointSelected: _handlePointSelected,
      ),
    );
  }
} 