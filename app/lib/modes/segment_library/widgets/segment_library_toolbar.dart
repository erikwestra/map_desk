import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_desk/core/models/segment.dart';
import 'package:map_desk/modes/segment_library/services/segment_library_service.dart';

/// Toolbar widget that provides actions for the selected segment.
class SegmentLibraryToolbar extends StatelessWidget {
  final Segment selectedSegment;
  final VoidCallback onDelete;
  final Function(Segment) onUpdate;

  const SegmentLibraryToolbar({
    super.key,
    required this.selectedSegment,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit segment',
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete segment',
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final nameController = TextEditingController(text: selectedSegment.name);
    final directionController = TextEditingController(text: selectedSegment.direction);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Segment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Segment Name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSegment.direction,
              decoration: const InputDecoration(
                labelText: 'Direction',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'oneWay',
                  child: Text('One Way'),
                ),
                DropdownMenuItem(
                  value: 'bidirectional',
                  child: Text('Bidirectional'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  directionController.text = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text,
                'direction': directionController.text,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      onUpdate(selectedSegment.copyWith(
        name: result['name']!,
        direction: result['direction']!,
      ));
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Segment'),
        content: Text('Are you sure you want to delete "${selectedSegment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onDelete();
    }
  }
} 