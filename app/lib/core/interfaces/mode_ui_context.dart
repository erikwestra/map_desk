import 'package:flutter/material.dart';
import '../widgets/segment_sidebar.dart';
import '../widgets/route_sidebar.dart';
import '../widgets/map_view.dart';
import '../widgets/status_bar.dart';

/// Context object that provides access to shared UI components for mode controllers.
class ModeUIContext {
  final Widget segmentSidebar;
  final Widget routeSidebar;
  final Widget mapView;
  final Widget statusBar;
  
  const ModeUIContext({
    required this.segmentSidebar,
    required this.routeSidebar,
    required this.mapView,
    required this.statusBar,
  });

  /// Creates a default ModeUIContext with standard widget instances.
  factory ModeUIContext.defaultContext() {
    return const ModeUIContext(
      segmentSidebar: SegmentSidebar(),
      routeSidebar: RouteSidebar(),
      mapView: MapView(),
      statusBar: StatusBar(),
    );
  }
} 