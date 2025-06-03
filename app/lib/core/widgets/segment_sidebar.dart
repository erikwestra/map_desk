import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_sidebar_service.dart';

/// Widget that displays the segment sidebar with search functionality.
class SegmentSidebar extends StatefulWidget {
  const SegmentSidebar({super.key});

  @override
  State<SegmentSidebar> createState() => _SegmentSidebarState();
}

class _SegmentSidebarState extends State<SegmentSidebar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final service = context.read<SegmentSidebarService>();
    service.updateSearchQuery(_searchController.text);
  }

  void _handleClearSearch() {
    _searchController.clear();
    final service = context.read<SegmentSidebarService>();
    service.clearSearchQuery();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentSidebarService>();

    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: _handleClearSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          // Segment list
          Expanded(
            child: service.segments.isEmpty
                ? Center(
                    child: Text(
                      'No segments found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  )
                : ListView.builder(
                    itemCount: service.segments.length,
                    itemBuilder: (context, index) {
                      final segment = service.segments[index];
                      final isSelected = service.selectedSegment?.id == segment.id;

                      return ListTile(
                        title: Text(
                          segment.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                        onTap: () {
                          service.selectSegment(segment);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 