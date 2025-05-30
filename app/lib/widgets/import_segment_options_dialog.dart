// ImportSegmentOptionsDialog widget for configuring segment creation options
import 'package:flutter/material.dart';
import '../models/segment_import_options.dart';

class ImportSegmentOptionsDialog extends StatefulWidget {
  final SegmentImportOptions initialOptions;

  const ImportSegmentOptionsDialog({
    super.key,
    required this.initialOptions,
  });

  @override
  State<ImportSegmentOptionsDialog> createState() => _ImportSegmentOptionsDialogState();
}

class _ImportSegmentOptionsDialogState extends State<ImportSegmentOptionsDialog> {
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
      title: const Text('Segment Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Segment Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Direction'),
          const SizedBox(height: 8),
          SegmentedButton<SegmentDirection>(
            segments: const [
              ButtonSegment<SegmentDirection>(
                value: SegmentDirection.oneWay,
                label: Text('One Way'),
              ),
              ButtonSegment<SegmentDirection>(
                value: SegmentDirection.bidirectional,
                label: Text('Bidirectional'),
              ),
            ],
            selected: {_selectedDirection},
            onSelectionChanged: (Set<SegmentDirection> selected) {
              setState(() {
                _selectedDirection = selected.first;
              });
            },
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
          child: const Text('Create'),
        ),
      ],
    );
  }
} 