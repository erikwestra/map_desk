import 'package:flutter/material.dart';

/// Service that manages the content displayed on the map.
/// Acts as a central store for map content and notifies listeners when content changes.
class MapViewService extends ChangeNotifier {
  List<Widget> _content = [];

  /// The current content to display on the map
  List<Widget> get content => _content;

  /// Update the map content
  void setContent(List<Widget> content) {
    _content = content;
    notifyListeners();
  }

  /// Clear the map content
  void clearContent() {
    _content = [];
    notifyListeners();
  }
} 