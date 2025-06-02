import 'package:flutter/material.dart';

/// A sidebar widget that displays the segment library.
class SegmentSidebar extends StatelessWidget {
  const SegmentSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: const Center(
        child: Text('Segment Sidebar'),
      ),
    );
  }
} 