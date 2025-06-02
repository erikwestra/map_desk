import 'package:flutter/material.dart';
import '../widgets/segment_sidebar.dart';
import '../widgets/route_sidebar.dart';
import '../widgets/status_bar.dart';
import '../services/map_view_service.dart';

/// Context object that provides access to shared UI components for mode controllers.
class ModeUIContext {
  final SegmentSidebar segmentSidebar;
  final RouteSidebar routeSidebar;
  final MapViewService mapViewService;
  final StatusBar statusBar;
  
  const ModeUIContext({
    required this.segmentSidebar,
    required this.routeSidebar,
    required this.mapViewService,
    required this.statusBar,
  });

  /// Creates a default ModeUIContext with standard widget instances.
  factory ModeUIContext.defaultContext() {
    return ModeUIContext(
      segmentSidebar: const SegmentSidebar(),
      routeSidebar: const RouteSidebar(),
      mapViewService: MapViewService(),
      statusBar: const StatusBar(),
    );
  }
} 