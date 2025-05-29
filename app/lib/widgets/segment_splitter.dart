import 'package:flutter/material.dart';
import '../models/segment.dart';
import '../models/gpx_track.dart';

class SegmentSplitter extends StatefulWidget {
  final GpxTrack track;
  final Function(Segment) onSegmentCreated;
  final VoidCallback onCancel;
  final int? startIndex;
  final int? endIndex;
  final void Function(int) onPointSelected;

  const SegmentSplitter({
    super.key,
    required this.track,
    required this.onSegmentCreated,
    required this.onCancel,
    required this.startIndex,
    required this.endIndex,
    required this.onPointSelected,
  });

  @override
  State<SegmentSplitter> createState() => _SegmentSplitterState();
}

class _SegmentSplitterState extends State<SegmentSplitter> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSegmentDialog() {
    if (widget.startIndex == null || widget.endIndex == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Segment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Segment Name',
                hintText: 'Enter a name for this segment',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description for this segment',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                final points = widget.track.points.map((p) => SegmentPoint(
                  latitude: p.latitude,
                  longitude: p.longitude,
                  elevation: p.elevation,
                )).toList();
                final segment = Segment.fromPoints(
                  name: _nameController.text,
                  allPoints: points,
                  startIndex: widget.startIndex!,
                  endIndex: widget.endIndex!,
                  description: _descriptionController.text.isEmpty
                      ? null
                      : _descriptionController.text,
                );
                widget.onSegmentCreated(segment);
                Navigator.pop(context);
                widget.onCancel();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select segment points',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.startIndex == null
                    ? 'Tap to select start point'
                    : widget.endIndex == null
                        ? 'Tap to select end point'
                        : 'Segment selected! Click Save to continue.',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  if (widget.startIndex != null && widget.endIndex != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _showSegmentDialog,
                      child: const Text('Save Segment'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 