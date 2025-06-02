import 'package:flutter/material.dart';

/// Service that manages the layout state of the application.
/// Handles sidebar visibility and layout preferences.
class LayoutService extends ChangeNotifier {
  bool _showLeftSidebar = true;
  bool _showRightSidebar = true;

  /// Whether the left sidebar (Segment Library) should be visible
  bool get showLeftSidebar => _showLeftSidebar;

  /// Whether the right sidebar (Current Route) should be visible
  bool get showRightSidebar => _showRightSidebar;

  /// Update the visibility of the sidebars
  void setSidebarVisibility({bool? left, bool? right}) {
    if (left != null) _showLeftSidebar = left;
    if (right != null) _showRightSidebar = right;
    notifyListeners();
  }
}
