import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/status_bar_service.dart';

/// A widget that displays the status bar at the bottom of the screen.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarService = context.watch<StatusBarService>();

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: statusBarService.content,
      ),
    );
  }
}
