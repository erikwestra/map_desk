// Menu items for the route builder mode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/route_builder_service.dart';
import '../../../../core/services/mode_service.dart';

class RouteBuilderMenu {
  /// Builds the Edit menu items for route builder mode
  static List<PlatformMenuItem> buildEditMenuItems(BuildContext context) {
    final isRouteBuilderMode = context.read<ModeService>().currentMode == AppMode.routeBuilder;
    final routeBuilder = context.watch<RouteBuilderService>();
    final canUndo = routeBuilder.canUndo;
    final canClear = routeBuilder.trackSegments.isNotEmpty;

    return [
      PlatformMenuItem(
        label: 'Undo',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
        onSelected: isRouteBuilderMode && canUndo ? () {
          routeBuilder.undo();
        } : null,
      ),
      PlatformMenuItem(
        label: 'Clear Track',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyK, meta: true),
        onSelected: isRouteBuilderMode && canClear ? () {
          routeBuilder.clear();
        } : null,
      ),
    ];
  }

  /// Builds the File menu items for route builder mode
  static List<PlatformMenuItem> buildFileMenuItems(BuildContext context) {
    final isRouteBuilderMode = context.read<ModeService>().currentMode == AppMode.routeBuilder;
    final routeBuilder = context.watch<RouteBuilderService>();
    final canSave = routeBuilder.currentTrack != null;

    return [
      PlatformMenuItem(
        label: 'Save Track',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
        onSelected: isRouteBuilderMode && canSave ? () {
          routeBuilder.save();
        } : null,
      ),
    ];
  }

  /// Builds the Add Segment menu item for route builder mode
  static PlatformMenuItem buildAddSegmentMenuItem(BuildContext context) {
    final isRouteBuilderMode = context.read<ModeService>().currentMode == AppMode.routeBuilder;
    return PlatformMenuItem(
      label: 'Add Segment',
      shortcut: const SingleActivator(LogicalKeyboardKey.enter),
      onSelected: isRouteBuilderMode ? () {
        final routeBuilder = context.read<RouteBuilderService>();
        if (routeBuilder.selectedSegment != null) {
          routeBuilder.addSelectedSegmentToRoute();
        }
      } : null,
    );
  }
} 