import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mode_service.dart';
import '../interfaces/mode_controller.dart';

/// A widget that displays the status bar at the bottom of the screen.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final modeService = context.watch<ModeService>();
    final currentMode = modeService.currentMode;

    return Container(
      height: 24,
      color: Colors.grey[200],
      child: Row(
        children: [
          const SizedBox(width: 8),
          if (currentMode == null)
            const Text('No mode selected')
          else
            Text(currentMode.modeName),
        ],
      ),
    );
  }
}
