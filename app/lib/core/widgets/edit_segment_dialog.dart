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
    
    // Select all text after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
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
        child: AlertDialog(
          title: Text(widget.title ?? 'Edit Segment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                onSubmitted: (_) => _handleSubmit(context),
                decoration: const InputDecoration(
                  labelText: 'Segment Name',
                  hintText: 'Enter a name for the segment',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'bidirectional',
                          groupValue: _selectedDirection,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedDirection = value;
                              });
                            }
                          },
                        ),
                        const Text('Bidirectional'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'oneWay',
                          groupValue: _selectedDirection,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedDirection = value;
                              });
                            }
                          },
                        ),
                        const Text('One Way'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (widget.showDeleteButton && widget.onDelete != null)
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Segment'),
                      content: const Text('Are you sure you want to delete this segment? This action cannot be undone.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    Navigator.of(context).pop('delete');
                    widget.onDelete?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            if (widget.showDeleteButton && widget.onDelete != null)
              const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _handleSubmit(context),
              child: const Text('Save'),
            ),
          ],
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