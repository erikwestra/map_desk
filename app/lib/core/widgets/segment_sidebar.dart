import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_sidebar_service.dart';
import '../models/segment.dart';

/// A resizable sidebar widget that displays a list of segments with search functionality.
class SegmentSidebar extends StatefulWidget {
  const SegmentSidebar({super.key});

  @override
  State<SegmentSidebar> createState() => _SegmentSidebarState();
}

class _SegmentSidebarState extends State<SegmentSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _width = 300.0;
  bool _isDragging = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentSidebarService>();

    return Stack(
      children: [
        SizedBox(
          width: _width,
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search segments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Segment list
              Expanded(
                child: FutureBuilder<List<Segment>>(
                  future: service.getAllSegments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading segments: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final segments = snapshot.data ?? [];
                    final filteredSegments = segments.where((segment) {
                      return segment.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filteredSegments.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No segments found'
                              : 'No segments match "$_searchQuery"',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredSegments.length,
                      itemBuilder: (context, index) {
                        final segment = filteredSegments[index];
                        final isSelected = service.selectedSegment?.id == segment.id;

                        return ListTile(
                          title: Text(segment.name),
                          subtitle: Text('${segment.points.length} points'),
                          selected: isSelected,
                          onTap: () => service.selectSegment(segment),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Resize handle
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragStart: (_) => setState(() => _isDragging = true),
              onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _width = (_width + details.delta.dx).clamp(200.0, 400.0);
                });
              },
              child: Container(
                width: 8,
                color: _isDragging 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Center(
                  child: Container(
                    width: 2,
                    height: 32,
                    color: _isDragging
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 