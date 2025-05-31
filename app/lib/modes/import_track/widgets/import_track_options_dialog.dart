// Dialog for configuring import options in the import track mode
import 'package:flutter/material.dart';
import '../models/segment_import_options.dart';

class ImportTrackOptionsDialog extends StatefulWidget {
  final SegmentImportOptions initialOptions;

  const ImportTrackOptionsDialog({
    super.key,
    required this.initialOptions,
  });

  @override
  State<ImportTrackOptionsDialog> createState() => _ImportTrackOptionsDialogState();
}

class _ImportTrackOptionsDialogState extends State<ImportTrackOptionsDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late SegmentDirection _selectedDirection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialOptions.segmentName);
    _numberController = TextEditingController(text: widget.initialOptions.nextSegmentNumber.toString());
    _selectedDirection = widget.initialOptions.direction;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Segment Options'),
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
          TextField(
            controller: _numberController,
            decoration: const InputDecoration(
              labelText: 'Next Segment Number',
              hintText: 'Enter the next segment number',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SegmentDirection>(
            value: _selectedDirection,
            decoration: const InputDecoration(
              labelText: 'Direction',
            ),
            items: SegmentDirection.values.map((direction) {
              return DropdownMenuItem(
                value: direction,
                child: Text(direction == SegmentDirection.oneWay ? 'One Way' : 'Bidirectional'),
              );
            }).toList(),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Validate segment number
            final number = int.tryParse(_numberController.text);
            if (number == null || number < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid segment number (1 or greater)'),
                ),
              );
              return;
            }

            Navigator.of(context).pop(SegmentImportOptions(
              segmentName: _nameController.text,
              direction: _selectedDirection,
              nextSegmentNumber: number,
            ));
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
} 