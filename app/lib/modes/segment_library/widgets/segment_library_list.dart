import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_map.dart';
import 'package:map_desk/modes/segment_library/widgets/segment_library_edit_dialog.dart';
import 'package:map_desk/core/widgets/segment_direction_indicator.dart';

/// Widget that displays an alphabetical list of segments in the sidebar.
class SegmentLibraryList extends StatefulWidget {
  const SegmentLibraryList({super.key});

  @override
  State<SegmentLibraryList> createState() => _SegmentLibraryListState();
}

class _SegmentLibraryListState extends State<SegmentLibraryList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SegmentLibraryService>();
    final segments = service.segments;
    final selectedSegment = service.selectedSegment;

    // Filter segments based on search query
    final filteredSegments = _searchQuery.isEmpty
        ? segments
        : segments.where((segment) =>
            segment.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch();
                      },
                    )
                  : null,
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
          child: filteredSegments.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No segments found'
                        : 'No segments match "$_searchQuery"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredSegments.length,
                  itemBuilder: (context, index) {
                    final segment = filteredSegments[index];
                    final isSelected = selectedSegment?.id == segment.id;

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SegmentDirectionIndicator(
                            direction: segment.direction,
                            size: 32,
                          ),
                          SizedBox(
                            width: 40, // Fixed width for the edit button area
                            child: isSelected
                                ? IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) => SegmentLibraryEditDialog(segment: segment),
                                      );

                                      if (result == 'delete') {
                                        // Show confirmation dialog
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Segment'),
                                            content: const Text('Are you sure you want to delete this segment?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Theme.of(context).colorScheme.error,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          await service.deleteSegment(segment);
                                        }
                                      } else if (result != null) {
                                        // Update segment with new values
                                        final updatedSegment = segment.copyWith(
                                          name: result['name'] as String,
                                          direction: result['direction'] as String,
                                        );
                                        await service.updateSegment(updatedSegment);
                                        // Refresh the segment list to ensure proper sorting
                                        await service.refreshSegments();
                                      }
                                    },
                                  )
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
} 