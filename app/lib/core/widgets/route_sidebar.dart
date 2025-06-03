import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/segment.dart';
import '../services/mode_service.dart';

/// A sidebar widget that displays the current route.
class RouteSidebar extends StatefulWidget {
  static final GlobalKey<_RouteSidebarState> globalKey = GlobalKey<_RouteSidebarState>();

  RouteSidebar() : super(key: globalKey);

  @override
  _RouteSidebarState createState() => _RouteSidebarState();
}

class _RouteSidebarState extends State<RouteSidebar> {
  List<Segment> _segments = [];

  void setSegments(List<Segment> segments) {
    setState(() {
      _segments = segments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;

    return Container(
      width: 300,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Text(
                  'Segments in Route',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          // Segments list
          Expanded(
            child: _segments.isEmpty
                ? const Center(
                    child: Text('No segments in route'),
                  )
                : ListView.builder(
                    itemCount: _segments.length,
                    itemBuilder: (context, index) {
                      final segment = _segments[index];
                      return ListTile(
                        title: Text(segment.name),
                        subtitle: Text('${segment.points.length} points'),
                      );
                    },
                  ),
          ),
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    modeService.currentMode?.handleEvent('route_undo', null);
                  },
                  child: const Text('Undo'),
                ),
                TextButton(
                  onPressed: () {
                    modeService.currentMode?.handleEvent('route_clear', null);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    modeService.currentMode?.handleEvent('route_save', null);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 