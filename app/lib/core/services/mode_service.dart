// Manages application mode state and navigation between different modes.
import 'package:flutter/material.dart';

enum AppMode {
  map,
  importTrack,
  segmentLibrary,
  routeBuilder,
}

class ModeService extends ChangeNotifier {
  AppMode _currentMode = AppMode.importTrack;

  AppMode get currentMode => _currentMode;

  void setMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }
} 