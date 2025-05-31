// Panel widget for selecting tracks and segments in the import track mode
import 'package:flutter/material.dart';
import '../models/selectable_item.dart';

class ImportTrackSelectionPanel extends StatelessWidget {
  final List<SelectableItem> items;
  final String? selectedId;
  final Function(SelectableItem) onItemSelected;
  final VoidCallback onOpenFile;
  final VoidCallback onCloseFile;

  const ImportTrackSelectionPanel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    required this.onOpenFile,
    required this.onCloseFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Item list
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                
                return ListTile(
                  selected: isSelected,
                  title: Text(item.name),
                  onTap: () => onItemSelected(item),
                  trailing: item.type == SelectableItemType.file
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onCloseFile,
                      )
                    : null,
                );
              },
            ),
          ),
          // File controls at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenFile,
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 