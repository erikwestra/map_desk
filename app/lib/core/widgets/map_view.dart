import 'package:flutter/material.dart';

/// A widget that displays the map content.
/// This is a placeholder that will be replaced with actual map functionality.
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'Map View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
