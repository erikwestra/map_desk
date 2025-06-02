import 'package:flutter/material.dart';

/// A widget that displays the right sidebar.
class CurrentRouteSidebar extends StatelessWidget {
  const CurrentRouteSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: const Center(
        child: Text('Current Route'),
      ),
    );
  }
}
