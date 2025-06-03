import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_sidebar_service.dart';
import '../widgets/segment_direction_indicator.dart';

/// Widget that displays the segment sidebar with search functionality.
class SegmentSidebar extends StatefulWidget {
  static final GlobalKey<_SegmentSidebarState> globalKey = GlobalKey<_SegmentSidebarState>();

  SegmentSidebar() : super(key: globalKey);

  @override
  State<SegmentSidebar> createState() => _SegmentSidebarState();
}

class _SegmentSidebarState extends State<SegmentSidebar> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to make an item at the given index visible
  void scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final itemHeight = 72.0; // Approximate height of ListTile
    final searchFieldHeight = 72.0; // Height of search field container (including padding)
    final itemPosition = index * itemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentScroll = _scrollController.position.pixels;

    // Check if the item is already visible in the viewport, accounting for search field
    if (itemPosition >= currentScroll && 
        itemPosition + itemHeight <= currentScroll + viewportHeight - searchFieldHeight) {
      return; // Item is already visible, no need to scroll
    }

    // Calculate the target scroll position to ensure the item is fully visible
    // Add padding to ensure the item is not hidden behind the search field
    final targetScroll = itemPosition - searchFieldHeight - 8.0; // 8.0 pixels of padding
    
    // Ensure we don't scroll beyond the bounds
    final maxScroll = _scrollController.position.maxScrollExtent;
    final minScroll = _scrollController.position.minScrollExtent;
    final boundedScroll = targetScroll.clamp(minScroll, maxScroll);

    _scrollController.animateTo(
      boundedScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          // Search field in its own container
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
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
          // Segment list in its own container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
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
                      controller: _scrollController,
                      itemCount: service.segments.length,
                      itemBuilder: (context, index) {
                        final segment = service.segments[index];
                        final isSelected = service.selectedSegment?.id == segment.id;

                        return ListTile(
                          key: ValueKey('segment_${segment.id}'),
                          title: Text(
                            segment.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                          onTap: () {
                            service.selectSegment(segment, shouldScroll: false);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SegmentDirectionIndicator(
                                direction: segment.direction,
                                size: 32,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 