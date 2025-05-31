// Widget for the unified selection panel showing file and segments
import 'package:flutter/material.dart';
import '../models/selectable_item.dart';

class SelectionPanel extends StatelessWidget {
  final List<SelectableItem> items;
  final String? selectedId;
  final Function(SelectableItem) onItemSelected;
  final VoidCallback onOpenFile;
  final VoidCallback onCloseFile;

  const SelectionPanel({
    super.key,
    required this.items,
    this.selectedId,
    required this.onItemSelected,
    required this.onOpenFile,
    required this.onCloseFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // List of items
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                
                return ListTile(
                  selected: isSelected,
                  title: Text(item.title),
                  onTap: () => onItemSelected(item),
                );
              },
            ),
          ),
          // Open/Close button at bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: onCloseFile,
                    child: const Text('Close'),
                  )
                else
                  TextButton(
                    onPressed: onOpenFile,
                    child: const Text('Open...'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 