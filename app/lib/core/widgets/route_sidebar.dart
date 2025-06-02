import 'package:flutter/material.dart';

/// A sidebar widget that displays the current route.
class RouteSidebar extends StatelessWidget {
  const RouteSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: const Center(
        child: Text('Route Sidebar'),
      ),
    );
  }
} 