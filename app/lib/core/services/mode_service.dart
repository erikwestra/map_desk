import 'package:flutter/material.dart';
import '../interfaces/mode_controller.dart';

/// Service that manages the different modes in MapDesk.
/// Handles mode switching and maintains the current mode state.
class ModeService extends ChangeNotifier {
  ModeController? _currentMode;
  final Map<String, ModeController> _modes = {};

  /// The currently active mode controller
  ModeController? get currentMode => _currentMode;

  /// Register a new mode controller
  void registerMode(ModeController mode) {
    _modes[mode.modeName] = mode;
    notifyListeners();
  }

  /// Switch to a different mode
  void switchMode(String modeName) {
    final newMode = _modes[modeName];
    if (newMode == null) {
      throw Exception('Mode $modeName not found');
    }

    // Deactivate current mode if it exists
    _currentMode?.onDeactivate();

    // Switch to new mode
    _currentMode = newMode;
    _currentMode?.onActivate();

    notifyListeners();
  }

  /// Get a specific mode controller by name
  ModeController? getMode(String modeName) => _modes[modeName];

  /// Save the current state of all modes
  Map<String, dynamic> saveState() {
    final state = <String, dynamic>{};
    for (final mode in _modes.values) {
      state[mode.modeName] = mode.getState();
    }
    return state;
  }

  /// Restore the state of all modes
  void restoreState(Map<String, dynamic> state) {
    for (final entry in state.entries) {
      final mode = _modes[entry.key];
      if (mode != null) {
        mode.restoreState(entry.value);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final mode in _modes.values) {
      mode.dispose();
    }
    super.dispose();
  }
}
