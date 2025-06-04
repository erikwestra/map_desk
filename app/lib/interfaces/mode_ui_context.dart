import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/segment_sidebar.dart';
import '../widgets/route_sidebar.dart';
import '../widgets/status_bar.dart';
import '../services/mode_service.dart';
import '../services/map_view_service.dart';
import '../services/status_bar_service.dart';
import '../services/segment_sidebar_service.dart';
import '../services/route_sidebar_service.dart';
import '../../main.dart';  // Import for navigatorKey and ServiceProvider

/// Context object that provides access to shared UI components and services.
/// This is passed to mode controllers to give them access to the UI.
class ModeUIContext {
  final ModeService modeService;
  final MapViewService mapViewService;
  final StatusBarService statusBarService;
  final SegmentSidebar segmentSidebar;
  final RouteSidebar routeSidebar;
  final StatusBar statusBar;
  final SegmentSidebarService segmentSidebarService;
  final RouteSidebarService routeSidebarService;
  
  ModeUIContext({
    required this.modeService,
    required this.mapViewService,
    required this.statusBarService,
    required this.segmentSidebar,
    required this.routeSidebar,
    required this.statusBar,
    required this.segmentSidebarService,
    required this.routeSidebarService,
  });

  /// Create a default context using the provided services
  static ModeUIContext defaultContext({
    required ModeService modeService,
    required MapViewService mapViewService,
    required StatusBarService statusBarService,
    required SegmentSidebarService segmentSidebarService,
    required RouteSidebarService routeSidebarService,
  }) {
    return ModeUIContext(
      modeService: modeService,
      mapViewService: mapViewService,
      statusBarService: statusBarService,
      segmentSidebar: SegmentSidebar(),
      routeSidebar: RouteSidebar(),
      statusBar: const StatusBar(),
      segmentSidebarService: segmentSidebarService,
      routeSidebarService: routeSidebarService,
    );
  }
} 