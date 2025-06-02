import 'package:flutter/material.dart';
import 'mode_ui_context.dart';

/// Interface for mode controllers that manage different application modes.
abstract class ModeController {
  /// The UI context providing access to shared UI components
  final ModeUIContext uiContext;

  /// Creates a new mode controller with the given UI context
  ModeController(this.uiContext);

  /// The name of this mode
  String get modeName;

  /// Whether to show the left sidebar
  bool get showLeftSidebar;

  /// Whether to show the right sidebar
  bool get showRightSidebar;

  /// Called when this mode is activated
  void onActivate();

  /// Called when this mode is deactivated
  void onDeactivate();

  /// Called when this mode is disposed
  void dispose();

  /// Handle an event from the UI
  /// 
  /// Events can be any type of interaction from the UI, such as:
  /// - Menu selections (open, save, undo, clear)
  /// - Map clicks
  /// - Sidebar selections
  /// - Button clicks
  /// - Drag and drop operations
  /// 
  /// The event type and data are passed as parameters.
  Future<void> handleEvent(String eventType, dynamic eventData) async {}
}
