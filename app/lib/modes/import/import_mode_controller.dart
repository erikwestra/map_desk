import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/interfaces/mode_controller.dart';
import '../../core/services/mode_service.dart';

/// Controller for the Import mode, which handles track import and segment creation.
class ImportModeController implements ModeController {
  @override
  String get modeName => 'Import';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  Widget buildLeftSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('Import Sidebar'),
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
          'Import Map Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget buildStatusBarContent(BuildContext context) {
    return const Text('Import Mode');
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
