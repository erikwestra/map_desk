import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/segment.dart';
import '../services/mode_service.dart';
import '../../main.dart';
import '../widgets/route_sidebar.dart';

/// Service that manages the state of the route sidebar
class RouteSidebarService extends ChangeNotifier {
  /// Get the current segments in the route
  List<Segment> get segments {
    final state = RouteSidebar.globalKey.currentState;
    return state?.segments ?? [];
  }

  /// Set the segments in the route
  void setSegments(List<Segment> segments) {
    final state = RouteSidebar.globalKey.currentState;
    if (state != null) {
      state.setSegments(segments);
      notifyListeners();
    }
  }
} 