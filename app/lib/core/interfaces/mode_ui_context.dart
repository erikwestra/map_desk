import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/segment_sidebar.dart';
import '../widgets/route_sidebar.dart';
import '../widgets/status_bar.dart';
import '../services/mode_service.dart';
import '../services/map_view_service.dart';
import '../../main.dart';  // Import for navigatorKey and ServiceProvider

/// Context object that provides access to shared UI components and services.
/// This is passed to mode controllers to give them access to the UI.
class ModeUIContext {
  final ModeService modeService;
  final MapViewService mapViewService;
  final SegmentSidebar segmentSidebar;
  final RouteSidebar routeSidebar;
  final StatusBar statusBar;
  
  ModeUIContext({
    required this.modeService,
    required this.mapViewService,
    required this.segmentSidebar,
    required this.routeSidebar,
    required this.statusBar,
  });

  /// Create a default context using the provided services
  static ModeUIContext defaultContext({
    required ModeService modeService,
    required MapViewService mapViewService,
  }) {
    return ModeUIContext(
      modeService: modeService,
      mapViewService: mapViewService,
      segmentSidebar: const SegmentSidebar(),
      routeSidebar: const RouteSidebar(),
      statusBar: const StatusBar(),
    );
  }
} 