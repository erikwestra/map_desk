import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/interfaces/mode_controller.dart';
import '../../core/services/mode_service.dart';

/// Controller for the View mode, which handles map viewing and navigation.
class ViewModeController implements ModeController {
  @override
  String get modeName => 'View';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  Widget buildLeftSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('View Sidebar'),
      ),
    );
  }

  @override
  Widget buildRightSidebar(BuildContext context) {
    return const Center(child: Text('Right Sidebar'));
  }

  @override
  Widget buildMapContent(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'View Map Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget buildStatusBarContent(BuildContext context) {
    return const Text('View Mode');
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  @override
  void dispose() {}

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}
}
