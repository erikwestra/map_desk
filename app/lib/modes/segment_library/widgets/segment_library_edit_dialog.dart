import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_desk/core/models/segment.dart';

class SegmentLibraryEditDialog extends StatefulWidget {
  final Segment segment;

  const SegmentLibraryEditDialog({
    super.key,
    required this.segment,
  });

  @override
  State<SegmentLibraryEditDialog> createState() => _SegmentLibraryEditDialogState();
}

class _SegmentLibraryEditDialogState extends State<SegmentLibraryEditDialog> {
  late final TextEditingController _nameController;
  late String _selectedDirection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.segment.name);
    _selectedDirection = widget.segment.direction;
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
            title: const Text('Edit Segment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
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
              TextButton(
                onPressed: () => Navigator.of(context).pop('delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
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