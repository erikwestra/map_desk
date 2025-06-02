import 'package:flutter/material.dart';

/// Interface for mode controllers that manage different application modes.
abstract class ModeController {
  /// The name of this mode
  String get modeName;

  /// Whether to show the left sidebar
  bool get showLeftSidebar;

  /// Whether to show the right sidebar
  bool get showRightSidebar;

  /// Builds the left sidebar widget
  Widget buildLeftSidebar(BuildContext context);

  /// Builds the right sidebar widget
  Widget buildRightSidebar(BuildContext context);

  /// Builds the main map content widget
  Widget buildMapContent(BuildContext context);

  /// Builds the left side of the status bar (mode-specific content)
  Widget buildStatusBarContent(BuildContext context);

  /// Called when this mode is activated
  void onActivate();

  /// Called when this mode is deactivated
  void onDeactivate();

  /// Called when this mode is disposed
  void dispose();

  /// Gets the current state of this mode
  Map<String, dynamic> getState();

  /// Restores the state of this mode
  void restoreState(Map<String, dynamic> state);
}
