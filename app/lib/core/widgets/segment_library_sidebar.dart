import 'package:flutter/material.dart';

/// A widget that displays the left sidebar.
class SegmentLibrarySidebar extends StatelessWidget {
  const SegmentLibrarySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: const Center(
        child: Text('Segments'),
      ),
    );
  }
} 