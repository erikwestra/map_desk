// Panel widget for selecting tracks and segments in the import track mode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selectable_item.dart';
import '../services/import_service.dart';

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
    final importService = context.watch<ImportService>();
    final hasTrack = importService.currentTrack != null;
    final theme = Theme.of(context);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
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
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                  ),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    onTap: () => onItemSelected(item),
                    trailing: item.type == SelectableItemType.file
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onCloseFile,
                        )
                      : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 