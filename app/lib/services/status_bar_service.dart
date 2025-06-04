import 'package:flutter/material.dart';

/// Service that manages the status bar content of the application.
/// Allows mode controllers to set custom content while maintaining the mode selector.
class StatusBarService extends ChangeNotifier {
  Widget? _content;

  /// The current content to display in the status bar
  Widget? get content => _content;

  /// Set the content to display in the status bar
  void setContent(Widget? content) {
    _content = content;
    notifyListeners();
  }

  /// Clear the current content
  void clearContent() {
    _content = null;
    notifyListeners();
  }
} 