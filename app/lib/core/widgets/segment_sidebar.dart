import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/segment_sidebar_service.dart';
import '../services/mode_service.dart';
import '../widgets/segment_direction_indicator.dart';
import '../models/sidebar_item.dart';
import '../models/segment.dart';
import '../../main.dart';

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

  Widget _buildSidebarItem(BuildContext context, SidebarItem item, SegmentSidebarService service) {
    final isSelected = service.selectedItem?.type == item.type && 
                      service.selectedItem?.value == item.value;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: ListTile(
        key: ValueKey('sidebar_item_${item.type}_${item.type == 'segment' ? (item.value as Segment).id : item.value}'),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.type == 'segment' ? (item.value as Segment).name : item.value.toString(),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: item.type == 'current_track' && service.currentTrack == null
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                      : isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                ),
              ),
            ),
            if (item.type == 'current_track' && service.currentTrack == null)
              TextButton(
                onPressed: () {
                  final modeService = Provider.of<ModeService>(context, listen: false);
                  modeService.currentMode?.handleEvent('menu_open', null);
                },
                child: const Text('Open'),
              ),
          ],
        ),
        tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
        onTap: item.selectable ? () {
          // Clear any existing selection
          service.clearSelection();
          // Select this item
          service.selectItem(item);
          // Force a rebuild to update the selection state
          setState(() {});
        } : null,
        trailing: item.type == 'segment' 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentDirectionIndicator(
                    direction: (item.value as Segment).direction,
                    size: 32,
                  ),
                ],
              )
            : item.type == 'current_track' && service.currentTrack != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SegmentDirectionIndicator(
                        direction: service.currentTrack!.direction,
                        size: 32,
                      ),
                    ],
                  )
                : null,
      ),
    );
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
          // Item list in its own container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: service.items.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: service.items.length,
                      itemBuilder: (context, index) {
                        final item = service.items[index];
                        return _buildSidebarItem(context, item, service);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 