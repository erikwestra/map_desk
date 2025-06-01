import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';

/// Toolbar widget that provides actions for the selected segment.
class SegmentLibraryToolbar extends StatelessWidget {
  final Segment selectedSegment;
  final Future<void> Function(Segment) onDelete;
  final Future<void> Function(Segment) onUpdate;

  const SegmentLibraryToolbar({
    super.key,
    required this.selectedSegment,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Segment'),
        content: Text(
          'Are you sure you want to delete "${selectedSegment.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onDelete(selectedSegment);
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    // TODO: Implement edit dialog
    await onUpdate(selectedSegment);
  }
} 