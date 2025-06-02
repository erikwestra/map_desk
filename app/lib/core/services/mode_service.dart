import 'package:flutter/material.dart';
import '../interfaces/mode_controller.dart';

/// Service that manages the current mode and mode switching.
class ModeService extends ChangeNotifier {
  ModeController? _currentMode;
  final Map<String, ModeController> _modes = {};

  /// The currently active mode controller
  ModeController? get currentMode => _currentMode;

  /// Initialize the mode service with a set of controllers
  void initializeControllers(Map<String, ModeController> controllers) {
    _modes.clear();
    _modes.addAll(controllers);
    
    // Start in View mode if available
    if (_modes.containsKey('View')) {
      switchMode('View');
    }
  }

  /// Switch to a different mode
  void switchMode(String modeName) {
    final newMode = _modes[modeName];
    if (newMode == null) {
      print('ModeService: Mode $modeName not found');
      return;
    }

    // Deactivate current mode if any
    _currentMode?.onDeactivate();

    // Switch to new mode
    _currentMode = newMode;
    _currentMode?.onActivate();

    notifyListeners();
  }

  /// Dispose of all mode controllers
  void dispose() {
    for (final mode in _modes.values) {
      mode.dispose();
    }
    _modes.clear();
    _currentMode = null;
    super.dispose();
  }
}
