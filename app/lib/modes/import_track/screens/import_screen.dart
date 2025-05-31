import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../services/gpx_service.dart';
import '../services/import_service.dart';
import '../models/simple_gpx_track.dart';
import '../models/segment.dart';
import '../widgets/import_track_map_view.dart';
import '../widgets/import_track_view.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start file picker immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _importGpxFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main import track view
          const ImportTrackView(),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _importGpxFile() async {
    final importService = context.read<ImportService>();
    
    setState(() {
      _isLoading = true;
    });

    try {
      await importService.importGpxFile(context);
    } catch (e) {
      if (mounted) {
        importService.setError('Failed to import GPX file: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
} 