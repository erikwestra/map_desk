import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable dialog for editing segment properties.
/// 
/// This dialog provides a consistent interface for editing segment names and directions
/// across the application. It supports keyboard shortcuts (Enter to submit, Escape to cancel)
/// and provides validation for required fields.
class EditSegmentDialog extends StatefulWidget {
  /// The name of the segment
  final String name;
  
  /// The direction of the segment ('bidirectional' or 'oneWay')
  final String direction;
  
  /// Optional callback when the segment is deleted
  final VoidCallback? onDelete;
  
  /// Optional title for the dialog
  final String? title;

  /// Whether to show the delete button
  final bool showDeleteButton;

  const EditSegmentDialog({
    super.key,
    required this.name,
    required this.direction,
    this.onDelete,
    this.title,
    this.showDeleteButton = true,
  });

  @override
  State<EditSegmentDialog> createState() => _EditSegmentDialogState();
}

class _EditSegmentDialogState extends State<EditSegmentDialog> {
  late final TextEditingController _nameController;
  late String _selectedDirection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _selectedDirection = widget.direction;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const _SubmitIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _CancelIntent(),
      },
      child: Actions(
        actions: {
          _SubmitIntent: CallbackAction<_SubmitIntent>(
            onInvoke: (_) => _handleSubmit(context),
          ),
          _CancelIntent: CallbackAction<_CancelIntent>(
            onInvoke: (_) => Navigator.of(context).pop(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: AlertDialog(
            title: Text(widget.title ?? 'Edit Segment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Segment Name',
                    hintText: 'Enter a name for the segment',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDirection,
                  decoration: const InputDecoration(
                    labelText: 'Direction',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'bidirectional',
                      child: Text('Bidirectional'),
                    ),
                    DropdownMenuItem(
                      value: 'oneWay',
                      child: Text('One Way'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDirection = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              if (widget.showDeleteButton && widget.onDelete != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop('delete');
                    widget.onDelete?.call();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              if (widget.showDeleteButton && widget.onDelete != null)
                const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _handleSubmit(context),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a segment name'),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'name': _nameController.text,
      'direction': _selectedDirection,
    });
  }
}

class _SubmitIntent extends Intent {
  const _SubmitIntent();
}

class _CancelIntent extends Intent {
  const _CancelIntent();
} 