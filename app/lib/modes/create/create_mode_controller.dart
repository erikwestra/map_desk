import 'package:flutter/material.dart';
import '../../core/interfaces/mode_controller.dart';

/// Controller for the Create mode, which handles route creation.
class CreateModeController implements ModeController {
  @override
  String get modeName => 'Create';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => true;

  @override
  Widget buildLeftSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('Create Left Sidebar'),
      ),
    );
  }

  @override
  Widget buildRightSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('Create Right Sidebar'),
      ),
    );
  }

  @override
  Widget buildMapContent(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'Create Map Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget buildStatusBarContent(BuildContext context) {
    return const Text('Create Mode');
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
