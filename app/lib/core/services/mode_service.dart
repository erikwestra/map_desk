import 'package:flutter/material.dart';
import '../interfaces/mode_controller.dart';

/// Service that manages the current mode and mode switching
class ModeService extends ChangeNotifier {
  final Map<String, ModeController> _modes = {};
  ModeController? _currentMode;

  /// The current mode controller
  ModeController? get currentMode => _currentMode;

  /// Register a new mode controller
  void registerMode(ModeController mode) {
    _modes[mode.modeName] = mode;
  }

  /// Switch to a different mode
  void switchMode(String modeName) {
    final newMode = _modes[modeName];
    if (newMode != null) {
      _currentMode?.onDeactivate();
      _currentMode = newMode;
      _currentMode?.onActivate();
      notifyListeners();
    }
  }

  /// Get a specific mode controller by name
  ModeController? getMode(String modeName) => _modes[modeName];

  @override
  void dispose() {
    for (final mode in _modes.values) {
      mode.dispose();
    }
    super.dispose();
  }
}
