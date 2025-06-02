import 'package:flutter/material.dart';
import '../widgets/segment_library_sidebar.dart';
import '../widgets/current_route_sidebar.dart';
import '../widgets/map_view.dart';
import '../widgets/status_bar.dart';

/// Context object that provides access to shared UI components for mode controllers.
class ModeUIContext {
  final Widget segmentLibrarySidebar;
  final Widget currentRouteSidebar;
  final Widget mapView;
  final Widget statusBar;
  
  const ModeUIContext({
    required this.segmentLibrarySidebar,
    required this.currentRouteSidebar,
    required this.mapView,
    required this.statusBar,
  });

  /// Creates a default ModeUIContext with standard widget instances.
  factory ModeUIContext.defaultContext() {
    return const ModeUIContext(
      segmentLibrarySidebar: SegmentLibrarySidebar(),
      currentRouteSidebar: CurrentRouteSidebar(),
      mapView: MapView(),
      statusBar: StatusBar(),
    );
  }
} 