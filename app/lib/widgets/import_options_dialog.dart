// Dialog for configuring import options
import 'package:flutter/material.dart';
import '../models/segment_import_options.dart';

class ImportOptionsDialog extends StatefulWidget {
  final SegmentImportOptions initialOptions;

  const ImportOptionsDialog({
    super.key,
    required this.initialOptions,
  });

  @override
  State<ImportOptionsDialog> createState() => _ImportOptionsDialogState();
}

class _ImportOptionsDialogState extends State<ImportOptionsDialog> {
  late final TextEditingController _nameController;
  late SegmentDirection _selectedDirection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialOptions.segmentName);
    _selectedDirection = widget.initialOptions.direction;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'New Segment Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'New Segment Direction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SegmentDirection>(
            segments: const [
              ButtonSegment<SegmentDirection>(
                value: SegmentDirection.oneWay,
                label: Text('One Way'),
                icon: Icon(Icons.arrow_forward),
              ),
              ButtonSegment<SegmentDirection>(
                value: SegmentDirection.bidirectional,
                label: Text('Bidirectional'),
                icon: Icon(Icons.compare_arrows),
              ),
            ],
            selected: {_selectedDirection},
            onSelectionChanged: (Set<SegmentDirection> selected) {
              setState(() {
                _selectedDirection = selected.first;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDirection == SegmentDirection.oneWay
                ? 'Segment can only be traversed in one direction'
                : 'Segment can be traversed in both directions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(SegmentImportOptions(
              segmentName: _nameController.text,
              direction: _selectedDirection,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 