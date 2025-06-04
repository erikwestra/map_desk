import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/segment.dart';
import '../services/mode_service.dart';
import '../services/route_sidebar_service.dart';

/// A sidebar widget that displays the current route.
class RouteSidebar extends StatefulWidget {
  static final GlobalKey<_RouteSidebarState> globalKey = GlobalKey<_RouteSidebarState>();

  RouteSidebar() : super(key: globalKey);

  @override
  _RouteSidebarState createState() => _RouteSidebarState();
}

class _RouteSidebarState extends State<RouteSidebar> {
  List<Segment> _segments = [];

  List<Segment> get segments => _segments;

  void setSegments(List<Segment> segments) {
    setState(() {
      _segments = segments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;
    final routeSidebarService = context.watch<RouteSidebarService>();
    final segments = routeSidebarService.segments;

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
            child: segments.isEmpty
                ? const Center(
                    child: Text('No segments in route'),
                  )
                : ListView.builder(
                    itemCount: segments.length,
                    itemBuilder: (context, index) {
                      final segment = segments[index];
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
                    modeService.currentMode?.handleEvent('menu_undo', null);
                  },
                  child: const Text('Undo'),
                ),
                TextButton(
                  onPressed: () {
                    modeService.currentMode?.handleEvent('menu_clear_track', null);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    modeService.currentMode?.handleEvent('menu_save_route', null);
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