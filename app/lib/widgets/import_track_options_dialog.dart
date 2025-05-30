// ImportTrackOptionsDialog widget for configuring GPX import options
import 'package:flutter/material.dart';
import 'package:map_desk/models/track_import_options.dart';

class ImportTrackOptionsDialog extends StatefulWidget {
  final TrackImportOptions initialOptions;

  const ImportTrackOptionsDialog({
    super.key,
    required this.initialOptions,
  });

  @override
  State<ImportTrackOptionsDialog> createState() => _ImportTrackOptionsDialogState();
}

class _ImportTrackOptionsDialogState extends State<ImportTrackOptionsDialog> {
  late final TextEditingController _segmentNameController;
  late TrackDirection _selectedDirection;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _segmentNameController = TextEditingController(text: widget.initialOptions.defaultSegmentName);
    _selectedDirection = widget.initialOptions.trackDirection;
  }

  @override
  void dispose() {
    _segmentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Track Options'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _segmentNameController,
              decoration: const InputDecoration(
                labelText: 'Default Segment Name',
                hintText: 'Enter a name for the segment',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a segment name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Track Direction'),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<TrackDirection>(
                  value: TrackDirection.forward,
                  groupValue: _selectedDirection,
                  onChanged: (TrackDirection? value) {
                    if (value != null) {
                      setState(() {
                        _selectedDirection = value;
                      });
                    }
                  },
                ),
                const Text('Forward'),
                const SizedBox(width: 16),
                Radio<TrackDirection>(
                  value: TrackDirection.backward,
                  groupValue: _selectedDirection,
                  onChanged: (TrackDirection? value) {
                    if (value != null) {
                      setState(() {
                        _selectedDirection = value;
                      });
                    }
                  },
                ),
                const Text('Backward'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(TrackImportOptions(
                defaultSegmentName: _segmentNameController.text,
                trackDirection: _selectedDirection,
              ));
            }
          },
          child: const Text('Import'),
        ),
      ],
    );
  }
} 